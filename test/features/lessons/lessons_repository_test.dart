import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/core/utils/profanity_filter.dart';
import 'package:future_self/features/lessons/data/lessons_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  const uid = 'user-1';
  late FakeFirebaseFirestore firestore;
  late LessonsRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(user);

    repository = LessonsRepository(
      FirebaseService(
        auth: auth,
        firestore: firestore,
        messaging: MockFirebaseMessaging(),
      ),
    );
  });

  Future<String> seedLesson() async {
    await repository.createLesson(
      'Keşke daha erken yatırım yapmaya başlasaydım.',
      Category.finance,
    );
    final snapshot = await firestore.collection('lessons').get();
    return snapshot.docs.single.id;
  }

  Future<Lesson> readLesson(String id) async {
    final doc = await firestore.collection('lessons').doc(id).get();
    return Lesson.fromMap(doc.id, doc.data()!);
  }

  test('createLesson küfürlü metni reddeder, temiz metni yazar', () async {
    expect(
      () => repository.createLesson('salak bir fikirdi', Category.career),
      throwsA(isA<ProfanityException>()),
    );
    expect((await firestore.collection('lessons').get()).docs, isEmpty);

    final id = await seedLesson();
    final lesson = await readLesson(id);
    expect(lesson.authorUid, uid);
    expect(lesson.category, Category.finance);
    expect(lesson.likeCount, 0);
  });

  test('toggleLike ekler/kaldırır ve sayacı günceller', () async {
    final id = await seedLesson();

    await repository.toggleLike(id);
    expect((await readLesson(id)).likeCount, 1);

    await repository.toggleLike(id);
    expect((await readLesson(id)).likeCount, 0);
    final marker = await firestore
        .collection('lessons')
        .doc(id)
        .collection('likes')
        .doc(uid)
        .get();
    expect(marker.exists, isFalse);
  });

  test('toggleSave marker\'ı uid alanıyla yazar (collectionGroup için)',
      () async {
    final id = await seedLesson();

    await repository.toggleSave(id);

    expect((await readLesson(id)).saveCount, 1);
    final marker = await firestore
        .collection('lessons')
        .doc(id)
        .collection('saves')
        .doc(uid)
        .get();
    expect(marker.data()?['uid'], uid);
  });

  test('addComment küfür kontrolü yapar, commentCount artırır', () async {
    final id = await seedLesson();

    expect(
      () => repository.addComment(id, 'bok gibi tavsiye'),
      throwsA(isA<ProfanityException>()),
    );

    await repository.addComment(id, 'Katılıyorum, ben de geç başladım.');

    expect((await readLesson(id)).commentCount, 1);
    final comments = await repository.watchComments(id).first;
    expect(comments.single.text, 'Katılıyorum, ben de geç başladım.');
    expect(comments.single.authorUid, uid);
  });

  test('reportLesson aynı kullanıcıyı iki kez saymaz', () async {
    final id = await seedLesson();

    await repository.reportLesson(id);
    await repository.reportLesson(id);

    expect((await readLesson(id)).reportCount, 1);
  });

  group('updateLesson (yazar-düzenleme senaryosu)', () {
    test('sadece verilen alanları değiştirir; authorUid ve sayaçlara '
        'dokunmaz', () async {
      final id = await seedLesson();
      await repository.toggleLike(id);
      final before = await readLesson(id);

      await repository.updateLesson(id, newText: 'Düzenlenmiş metin.');

      final after = await readLesson(id);
      expect(after.text, 'Düzenlenmiş metin.');
      expect(after.category, before.category);
      expect(after.authorUid, before.authorUid);
      expect(after.likeCount, before.likeCount);

      await repository.updateLesson(id, newCategory: Category.health);
      final recategorized = await readLesson(id);
      expect(recategorized.category, Category.health);
      expect(recategorized.text, 'Düzenlenmiş metin.');
    });

    test('düzenlemede de küfür filtresi çalışır', () async {
      final id = await seedLesson();

      expect(
        () => repository.updateLesson(id, newText: 'salak bir düzenleme'),
        throwsA(isA<ProfanityException>()),
      );
      expect((await readLesson(id)).text, isNot(contains('salak')));
    });
  });

  test('sayaç güncellemeleri (toggle) sadece sayaç alanlarını değiştirir',
      () async {
    final id = await seedLesson();
    final before = await readLesson(id);

    await repository.toggleLike(id);
    await repository.toggleSave(id);

    final after = await readLesson(id);
    // Kural senaryosu (b)'nin istemci ayak izi: içerik alanları sabit.
    expect(after.text, before.text);
    expect(after.category, before.category);
    expect(after.authorUid, before.authorUid);
    expect(after.likeCount, 1);
    expect(after.saveCount, 1);
  });

  test('deleteLesson alt koleksiyonları da temizler', () async {
    final id = await seedLesson();
    await repository.toggleLike(id);
    await repository.toggleSave(id);
    await repository.addComment(id, 'Güzel paylaşım.');
    await repository.reportLesson(id);

    await repository.deleteLesson(id);

    final lessonDoc = await firestore.collection('lessons').doc(id).get();
    expect(lessonDoc.exists, isFalse);
    for (final subcollection in ['comments', 'likes', 'saves', 'reports']) {
      final docs = await firestore
          .collection('lessons')
          .doc(id)
          .collection(subcollection)
          .get();
      expect(docs.docs, isEmpty, reason: '$subcollection temizlenmedi');
    }
  });

  test('watchSavedLessons kaydedilenleri getirir', () async {
    final id = await seedLesson();
    await repository.toggleSave(id);

    // fake_cloud_firestore quirk'i: auto-id üst doküman + transaction
    // ile yazılmış alt dokümanda İLK collectionGroup sorgusu boş döner,
    // ikincisi görür. Gerçek Firestore'da bu davranış yok; ısınma
    // sorgusu sadece fake içindir.
    await firestore.collectionGroup('saves').get();

    final saved = await repository.watchSavedLessons().first;

    expect(saved, hasLength(1));
    expect(saved.single.id, id);
  });
}
