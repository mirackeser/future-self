import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';
import '../../../core/utils/profanity_filter.dart';

/// Life Lessons'ın Firestore erişim katmanı.
///
/// Yapı: /lessons/{lessonId} (herkese açık, root seviyede) + alt
/// koleksiyonlar: comments, likes/{uid}, saves/{uid}, reports/{uid}.
/// Marker dokümanlar (like/save/report) kullanıcı başına tekliği,
/// lesson üzerindeki sayaçlar da hızlı listelemeyi sağlar.
class LessonsRepository {
  LessonsRepository(this._firebase);

  final FirebaseService _firebase;

  CollectionReference<Map<String, dynamic>> get _lessonsRef =>
      _firebase.firestore.collection('lessons');

  String get _uid {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Lesson işlemleri için oturum açık olmalı.');
    }
    return user.uid;
  }

  /// Küfür filtresinden geçen paylaşımı akışa ekler.
  ///
  /// Uygunsuz içerikte [ProfanityException] fırlatır; UI yakalayıp
  /// kullanıcıya mesaj gösterir.
  Future<void> createLesson(String text, Category category) {
    if (containsProfanity(text)) {
      throw const ProfanityException();
    }
    final docRef = _lessonsRef.doc();
    final lesson = Lesson(
      id: docRef.id,
      authorUid: _uid,
      text: text.trim(),
      category: category,
      createdAt: DateTime.now(),
    );
    return docRef.set(lesson.toMap());
  }

  /// Akış: en yeni önce, son 50 paylaşım, opsiyonel kategori filtresi.
  ///
  /// Not: kategori filtresi + createdAt sıralaması gerçek Firestore'da
  /// composite index ister (Console ilk sorguda oluşturma linki verir).
  Stream<List<Lesson>> watchFeed({Category? filterCategory}) {
    Query<Map<String, dynamic>> query = _lessonsRef;
    if (filterCategory != null) {
      query = query.where('category', isEqualTo: filterCategory.name);
    }
    return query
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs) Lesson.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Kullanıcının kaydettiği lesson'lar, en son kaydedilen önce.
  ///
  /// Save marker'ları uid alanıyla yazılır ve collectionGroup('saves')
  /// sorgusuyla bulunur (users altında ayna koleksiyon tutup çift yazma
  /// yapmamak için tek kaynak bu). İlgili lesson'lar id'lere göre
  /// whereIn parçalarıyla çekilir. Not: collection group sorgusu
  /// 'saves' için uid alanı index'i ister.
  Stream<List<Lesson>> watchSavedLessons() {
    return _firebase.firestore
        .collectionGroup('saves')
        .where('uid', isEqualTo: _uid)
        .snapshots()
        .asyncMap((snapshot) async {
      // En son kaydedilen önce gelecek şekilde lesson id sırası.
      final saveDocs = [...snapshot.docs]..sort((a, b) {
          final aAt = a.data()['createdAt'] as Timestamp?;
          final bAt = b.data()['createdAt'] as Timestamp?;
          if (aAt == null || bAt == null) return 0;
          return bAt.compareTo(aAt);
        });
      final lessonIds = [
        for (final doc in saveDocs)
          if (doc.reference.parent.parent != null)
            doc.reference.parent.parent!.id,
      ];
      if (lessonIds.isEmpty) return const <Lesson>[];

      // Kaydedilen liste küçük (feed limiti mertebesinde); doküman
      // başına paralel get, whereIn parçalama karmaşasından daha sade
      // ve okuma maliyeti aynı.
      final docs = await Future.wait(
        [for (final id in lessonIds) _lessonsRef.doc(id).get()],
      );
      return [
        for (final doc in docs)
          if (doc.exists) Lesson.fromMap(doc.id, doc.data()!),
      ];
    });
  }

  /// Yazarın kendi gönderisini düzenlemesi; sadece verilen alanlar yazılır.
  ///
  /// Yeni metin de küfür filtresinden geçer — düzenleme, paylaşımdaki
  /// filtreyi bypass edememeli.
  Future<void> updateLesson(
    String lessonId, {
    String? newText,
    Category? newCategory,
  }) async {
    if (newText != null && containsProfanity(newText)) {
      throw const ProfanityException();
    }
    final update = <String, dynamic>{};
    if (newText != null) update['text'] = newText.trim();
    if (newCategory != null) update['category'] = newCategory.name;
    if (update.isEmpty) return;
    await _lessonsRef.doc(lessonId).update(update);
  }

  /// Gönderiyi alt koleksiyonlarıyla birlikte siler (Firestore cascade
  /// yapmaz). Get + batch delete, birkaç yüz doküman varsayımıyla MVP
  /// için yeterli; çok büyük ölçekte silme bir Cloud Function'a
  /// taşınmalı. Yorumların kendi reports alt koleksiyonları da o
  /// aşamada temizlenecek (MVP'de öksüz kalabilir).
  Future<void> deleteLesson(String lessonId) async {
    final lessonRef = _lessonsRef.doc(lessonId);
    final batch = _firebase.firestore.batch();

    for (final subcollection in ['comments', 'likes', 'saves', 'reports']) {
      final docs = await lessonRef.collection(subcollection).get();
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
    }
    batch.delete(lessonRef);
    await batch.commit();
  }

  /// Tek bir lesson'ı canlı izler (yorum ekranı için); silinmişse null.
  Stream<Lesson?> watchLesson(String lessonId) {
    return _lessonsRef.doc(lessonId).snapshots().map(
          (doc) => doc.exists ? Lesson.fromMap(doc.id, doc.data()!) : null,
        );
  }

  /// Mevcut kullanıcı bu lesson'ı beğenmiş mi (marker varlığı).
  Stream<bool> watchIsLiked(String lessonId) =>
      _watchMarker(lessonId, 'likes');

  /// Mevcut kullanıcı bu lesson'ı kaydetmiş mi (marker varlığı).
  Stream<bool> watchIsSaved(String lessonId) =>
      _watchMarker(lessonId, 'saves');

  Stream<bool> _watchMarker(String lessonId, String subcollection) {
    return _lessonsRef
        .doc(lessonId)
        .collection(subcollection)
        .doc(_uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Kullanıcının kendi paylaşımları (rozet değerlendirmesi için).
  Future<List<Lesson>> fetchMyLessons() async {
    final snapshot =
        await _lessonsRef.where('authorUid', isEqualTo: _uid).get();
    return [
      for (final doc in snapshot.docs) Lesson.fromMap(doc.id, doc.data()),
    ];
  }

  /// Kullanıcının toplam yorum sayısı (rozet değerlendirmesi için).
  /// Challenge'daki collection-group deseni; equality-only olduğundan
  /// composite index gerekmez.
  Future<int> countMyComments() async {
    final snapshot = await _firebase.firestore
        .collectionGroup('comments')
        .where('authorUid', isEqualTo: _uid)
        .get();
    return snapshot.docs.length;
  }

  Future<void> toggleLike(String lessonId) =>
      _toggleMarker(lessonId, subcollection: 'likes', counterField: 'likeCount');

  Future<void> toggleSave(String lessonId) =>
      _toggleMarker(lessonId, subcollection: 'saves', counterField: 'saveCount');

  Future<void> _toggleMarker(
    String lessonId, {
    required String subcollection,
    required String counterField,
  }) async {
    final uid = _uid;
    final lessonRef = _lessonsRef.doc(lessonId);
    final markerRef = lessonRef.collection(subcollection).doc(uid);

    await _firebase.firestore.runTransaction((tx) async {
      final marker = await tx.get(markerRef);
      if (marker.exists) {
        tx.delete(markerRef);
        tx.update(lessonRef, {counterField: FieldValue.increment(-1)});
      } else {
        tx.set(markerRef, {
          'uid': uid,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
        tx.update(lessonRef, {counterField: FieldValue.increment(1)});
      }
    });
  }

  /// Küfür filtresinden geçen yorumu ekler, commentCount'u artırır.
  Future<void> addComment(String lessonId, String text) async {
    if (containsProfanity(text)) {
      throw const ProfanityException();
    }
    final lessonRef = _lessonsRef.doc(lessonId);
    final commentRef = lessonRef.collection('comments').doc();
    final comment = LessonComment(
      id: commentRef.id,
      lessonId: lessonId,
      authorUid: _uid,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    await _firebase.firestore.runTransaction((tx) async {
      tx.set(commentRef, comment.toMap());
      tx.update(lessonRef, {'commentCount': FieldValue.increment(1)});
    });
  }

  /// Yorumlar, en yeni üstte.
  Stream<List<LessonComment>> watchComments(String lessonId) {
    return _lessonsRef
        .doc(lessonId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              LessonComment.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Paylaşımı bildirir; aynı kullanıcı ikinci kez sayılmaz.
  /// Otomatik gizleme yok (MVP) — sayaç moderasyon için tutulur.
  Future<void> reportLesson(String lessonId) {
    final lessonRef = _lessonsRef.doc(lessonId);
    return _reportOnce(
      reportRef: lessonRef.collection('reports').doc(_uid),
      counterRef: lessonRef,
    );
  }

  /// Yorumu bildirir; aynı kullanıcı ikinci kez sayılmaz.
  Future<void> reportComment(String lessonId, String commentId) {
    final commentRef =
        _lessonsRef.doc(lessonId).collection('comments').doc(commentId);
    return _reportOnce(
      reportRef: commentRef.collection('reports').doc(_uid),
      counterRef: commentRef,
    );
  }

  Future<void> _reportOnce({
    required DocumentReference<Map<String, dynamic>> reportRef,
    required DocumentReference<Map<String, dynamic>> counterRef,
  }) async {
    final uid = _uid;
    await _firebase.firestore.runTransaction((tx) async {
      final existing = await tx.get(reportRef);
      if (existing.exists) return; // zaten bildirmiş, tekrar sayma
      tx.set(reportRef, {
        'uid': uid,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      tx.update(counterRef, {'reportCount': FieldValue.increment(1)});
    });
  }
}

final lessonsRepositoryProvider = Provider<LessonsRepository>((ref) {
  return LessonsRepository(ref.watch(firebaseServiceProvider));
});
