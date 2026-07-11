import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/core/services/local_notifications_service.dart';
import 'package:future_self/features/letters/data/letters_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockLocalNotificationsService extends Mock
    implements LocalNotificationsService {}

void main() {
  const uid = 'user-1';
  late FakeFirebaseFirestore firestore;
  late MockLocalNotificationsService notifications;
  late LettersRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    notifications = MockLocalNotificationsService();
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(user);

    repository = LettersRepository(
      FirebaseService(
        auth: auth,
        firestore: firestore,
        messaging: MockFirebaseMessaging(),
      ),
      notifications,
    );

    when(
      () => notifications.scheduleLetterNotification(
        letterId: any(named: 'letterId'),
        deliveryDate: any(named: 'deliveryDate'),
        previewText: any(named: 'previewText'),
      ),
    ).thenAnswer((_) async => 111);
    when(
      () => notifications.showLetterDeliveredNow(
        letterId: any(named: 'letterId'),
        previewText: any(named: 'previewText'),
      ),
    ).thenAnswer((_) async => 222);
  });

  Future<List<FutureLetter>> readLetters() async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('letters')
        .get();
    return [
      for (final doc in snapshot.docs)
        FutureLetter.fromMap(doc.id, doc.data()),
    ];
  }

  Future<void> seedGoal({required double currentValue}) {
    final goal = Goal(
      id: 'g1',
      userId: uid,
      category: Category.health,
      title: 'Kilo',
      metricTemplateId: 'health_weight',
      type: MetricType.numeric,
      initialValue: 85,
      currentValue: currentValue,
      targetValue: 75,
      createdAt: DateTime(2026, 1, 1),
    );
    return firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('g1')
        .set(goal.toMap());
  }

  group('createLetter', () {
    test('fixedDate: bildirim zamanlanır, id ve tarih kaydedilir', () async {
      final deliveryDate = DateTime(2026, 10, 8);

      await repository.createLetter(
        text: 'Merhaba gelecekteki ben, umarım koşuyorsundur.',
        deliveryMode: LetterDeliveryMode.fixedDate,
        deliveryDate: deliveryDate,
      );

      final letter = (await readLetters()).single;
      expect(letter.deliveryMode, LetterDeliveryMode.fixedDate);
      expect(letter.deliveryDate, deliveryDate);
      expect(letter.notificationId, 111);
      expect(letter.isOpened, isFalse);
      verify(
        () => notifications.scheduleLetterNotification(
          letterId: letter.id,
          deliveryDate: deliveryDate,
          previewText: any(named: 'previewText'),
        ),
      ).called(1);
    });

    test('goalCompletion: bildirim ZAMANLANMAZ, hedefe bağlanır', () async {
      await repository.createLetter(
        text: 'Hedefe ulaştıysan bunu okuyorsun demektir.',
        deliveryMode: LetterDeliveryMode.goalCompletion,
        relatedGoalId: 'g1',
      );

      final letter = (await readLetters()).single;
      expect(letter.deliveryMode, LetterDeliveryMode.goalCompletion);
      expect(letter.relatedGoalId, 'g1');
      expect(letter.deliveryDate, isNull);
      expect(letter.notificationId, 0);
      verifyNever(
        () => notifications.scheduleLetterNotification(
          letterId: any(named: 'letterId'),
          deliveryDate: any(named: 'deliveryDate'),
          previewText: any(named: 'previewText'),
        ),
      );
    });
  });

  group('checkGoalCompletionLetters', () {
    test('%100 hedefte anlık bildirim + deliveryDate damgası', () async {
      await seedGoal(currentValue: 75); // 85→75 hedefi, tam %100
      await repository.createLetter(
        text: 'Başardın! Bunu sana aylar önce yazdım.',
        deliveryMode: LetterDeliveryMode.goalCompletion,
        relatedGoalId: 'g1',
      );

      await repository.checkGoalCompletionLetters('g1');

      final letter = (await readLetters()).single;
      expect(letter.deliveryDate, isNotNull);
      expect(letter.notificationId, 222);
      verify(
        () => notifications.showLetterDeliveredNow(
          letterId: letter.id,
          previewText: any(named: 'previewText'),
        ),
      ).called(1);
    });

    test('ikinci çağrı tekrar bildirmez (deliveryDate koruması)', () async {
      await seedGoal(currentValue: 75);
      await repository.createLetter(
        text: 'Tek seferlik mektup.',
        deliveryMode: LetterDeliveryMode.goalCompletion,
        relatedGoalId: 'g1',
      );

      await repository.checkGoalCompletionLetters('g1');
      await repository.checkGoalCompletionLetters('g1');

      verify(
        () => notifications.showLetterDeliveredNow(
          letterId: any(named: 'letterId'),
          previewText: any(named: 'previewText'),
        ),
      ).called(1);
    });

    test('hedef %100 değilse hiçbir şey olmaz', () async {
      await seedGoal(currentValue: 80); // %50
      await repository.createLetter(
        text: 'Henüz erken.',
        deliveryMode: LetterDeliveryMode.goalCompletion,
        relatedGoalId: 'g1',
      );

      await repository.checkGoalCompletionLetters('g1');

      expect((await readLetters()).single.deliveryDate, isNull);
      verifyNever(
        () => notifications.showLetterDeliveredNow(
          letterId: any(named: 'letterId'),
          previewText: any(named: 'previewText'),
        ),
      );
    });

    test('başka hedefin mektubuna dokunmaz', () async {
      await seedGoal(currentValue: 75);
      await repository.createLetter(
        text: 'Bu başka bir hedefin mektubu.',
        deliveryMode: LetterDeliveryMode.goalCompletion,
        relatedGoalId: 'baska-hedef',
      );

      await repository.checkGoalCompletionLetters('g1');

      expect((await readLetters()).single.deliveryDate, isNull);
    });
  });

  test('markOpened isOpened yapar', () async {
    await repository.createLetter(
      text: 'Açılacak mektup.',
      deliveryMode: LetterDeliveryMode.fixedDate,
      deliveryDate: DateTime(2026, 8, 1),
    );
    final letter = (await readLetters()).single;

    await repository.markOpened(letter.id);

    expect((await readLetters()).single.isOpened, isTrue);
  });

  test('previewOf ilk kelimeleri alır', () {
    expect(LettersRepository.previewOf('kısa metin'), 'kısa metin');
    expect(
      LettersRepository.previewOf(
        'bir iki üç dört beş altı yedi sekiz dokuz',
      ),
      'bir iki üç dört beş altı…',
    );
  });
}
