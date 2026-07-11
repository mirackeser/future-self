import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_service.dart';
import 'local_notifications_service.dart';

/// Hesap silme sırasında yeniden kimlik doğrulama gerektiğinde hangi
/// yöntemin kullanılacağı (kullanıcının providerData'sından tespit edilir).
enum ReauthMethod { password, google, apple }

/// Auth kullanıcısı silinirken requires-recent-login alındı: veri
/// silinmiş durumda, UI [method] ile yeniden doğrulama yapıp
/// [AccountDeletionService.deleteAuthUser]'ı tekrar çağırmalı.
class RequiresRecentLoginException implements Exception {
  const RequiresRecentLoginException(this.method);

  final ReauthMethod method;

  @override
  String toString() => 'RequiresRecentLoginException(${method.name})';
}

/// Hesabı tüm verileriyle birlikte kalıcı olarak siler (App Store
/// zorunluluğu + GDPR).
///
/// Client-side silme MVP varsayımı: kullanıcı başına birkaç yüz doküman.
/// Çok büyük ölçekte bu iş bir Cloud Function'a taşınmalı.
class AccountDeletionService {
  AccountDeletionService(this._firebase, this._notifications);

  final FirebaseService _firebase;
  final LocalNotificationsService _notifications;

  /// users/{uid} altındaki bilinen alt koleksiyonlar. Client SDK alt
  /// koleksiyonları listeleyemez; yeni bir koleksiyon eklenirse buraya
  /// da eklenmeli.
  static const List<String> userSubcollections = [
    'goals',
    'missions',
    'reflections',
    'chapters',
    'letters',
    'weeklyChallenges',
  ];

  FirebaseFirestore get _firestore => _firebase.firestore;

  /// Sırayla: kendi lesson'ları → başkalarındaki yorum/marker izleri →
  /// users/{uid} alt koleksiyonları (mektup bildirimleri iptal edilerek)
  /// → users/{uid} dokümanı → auth kullanıcısı.
  ///
  /// Son adım requires-recent-login verirse [RequiresRecentLoginException]
  /// fırlatılır; veri o noktada silinmiştir, akış yeniden doğrulama
  /// sonrası sadece [deleteAuthUser] ile tamamlanır. Yarıda kalan bir
  /// silme tekrar çağrılabilir — sorgular boş döner, adımlar idempotent.
  Future<void> deleteAccount() async {
    final user = _requireUser();
    final uid = user.uid;

    await _deleteMyLessons(uid);
    await _deleteMyComments(uid);
    // Beğeni/kayıt marker'ları uid taşır (GDPR); sayaçları da düzeltilir.
    await _deleteMyMarkers(uid, 'likes', counterField: 'likeCount');
    await _deleteMyMarkers(uid, 'saves', counterField: 'saveCount');
    // Report marker'ı da uid taşır ama sayaç moderasyon sinyali olarak
    // kalır (silinen kullanıcı tekrar bildiremeyeceği için tutarlı).
    await _deleteMyMarkers(uid, 'reports');
    await _deleteUserData(uid);
    await deleteAuthUser();
  }

  /// Sadece auth kullanıcısını siler (deleteAccount'un son adımı;
  /// yeniden doğrulama sonrası tek başına da çağrılır).
  Future<void> deleteAuthUser() async {
    final user = _requireUser();
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw RequiresRecentLoginException(_detectReauthMethod(user));
      }
      rethrow;
    }
  }

  /// Kullanıcının kendi paylaştığı lesson'lar, alt koleksiyonlarıyla.
  /// (LessonsRepository.deleteLesson ile aynı mantık; core→feature
  /// bağımlılığı kurmamak için burada tekrarlanır.)
  Future<void> _deleteMyLessons(String uid) async {
    final lessons = await _firestore
        .collection('lessons')
        .where('authorUid', isEqualTo: uid)
        .get();
    for (final lesson in lessons.docs) {
      final refs = <DocumentReference<Map<String, dynamic>>>[];
      for (final sub in ['comments', 'likes', 'saves', 'reports']) {
        final docs = await lesson.reference.collection(sub).get();
        refs.addAll(docs.docs.map((d) => d.reference));
      }
      refs.add(lesson.reference);
      await _deleteRefs(refs);
    }
  }

  /// Başkalarının gönderilerine yapılan yorumlar; lesson hâlâ
  /// duruyorsa commentCount da transaction içinde azaltılır.
  Future<void> _deleteMyComments(String uid) async {
    final comments = await _firestore
        .collectionGroup('comments')
        .where('authorUid', isEqualTo: uid)
        .get();
    for (final comment in comments.docs) {
      final lessonRef = comment.reference.parent.parent;
      await _firestore.runTransaction((tx) async {
        if (lessonRef != null) {
          final lesson = await tx.get(lessonRef);
          if (lesson.exists) {
            tx.update(lessonRef, {'commentCount': FieldValue.increment(-1)});
          }
        }
        tx.delete(comment.reference);
      });
    }
  }

  /// Kullanıcının like/save/report marker'ları (uid alanıyla yazılır,
  /// bkz. LessonsRepository). [counterField] verilirse lesson'daki
  /// sayaç da azaltılır.
  Future<void> _deleteMyMarkers(
    String uid,
    String subcollection, {
    String? counterField,
  }) async {
    final markers = await _firestore
        .collectionGroup(subcollection)
        .where('uid', isEqualTo: uid)
        .get();
    for (final marker in markers.docs) {
      final parentRef = marker.reference.parent.parent;
      await _firestore.runTransaction((tx) async {
        if (counterField != null && parentRef != null) {
          final parent = await tx.get(parentRef);
          if (parent.exists) {
            tx.update(parentRef, {counterField: FieldValue.increment(-1)});
          }
        }
        tx.delete(marker.reference);
      });
    }
  }

  /// users/{uid} alt koleksiyonları + dokümanın kendisi. Mektup
  /// bildirimleri, letters dokümanları silinmeden ÖNCE (id'ler henüz
  /// okunabilirken) iptal edilir.
  Future<void> _deleteUserData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    for (final sub in userSubcollections) {
      final docs = await userRef.collection(sub).get();
      final refs = <DocumentReference<Map<String, dynamic>>>[];
      for (final doc in docs.docs) {
        if (sub == 'goals') {
          final history = await doc.reference.collection('history').get();
          refs.addAll(history.docs.map((d) => d.reference));
        }
        if (sub == 'letters') {
          await _cancelLetterNotification(doc.data());
        }
        refs.add(doc.reference);
      }
      await _deleteRefs(refs);
    }

    await userRef.delete();
  }

  Future<void> _cancelLetterNotification(Map<String, dynamic> letter) async {
    final notificationId = letter['notificationId'] as int? ?? 0;
    if (notificationId == 0) return;
    try {
      await _notifications.cancelNotification(notificationId);
    } catch (_) {
      // Bildirim iptali silmeyi durdurmamalı; en kötü ihtimalle ölü
      // bir bildirim kalır, tıklanınca mektup bulunamaz ekranı açılır.
    }
  }

  /// Firestore batch limiti 500; payla parçalayarak siler.
  Future<void> _deleteRefs(
    List<DocumentReference<Map<String, dynamic>>> refs,
  ) async {
    const chunkSize = 450;
    for (var i = 0; i < refs.length; i += chunkSize) {
      final batch = _firestore.batch();
      for (final ref in refs.skip(i).take(chunkSize)) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  static ReauthMethod _detectReauthMethod(User user) {
    for (final info in user.providerData) {
      switch (info.providerId) {
        case 'google.com':
          return ReauthMethod.google;
        case 'apple.com':
          return ReauthMethod.apple;
        case 'password':
          return ReauthMethod.password;
      }
    }
    return ReauthMethod.password;
  }

  User _requireUser() {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Hesap silme için oturum açık olmalı.');
    }
    return user;
  }
}

final accountDeletionServiceProvider = Provider<AccountDeletionService>((ref) {
  return AccountDeletionService(
    ref.watch(firebaseServiceProvider),
    ref.watch(localNotificationsServiceProvider),
  );
});
