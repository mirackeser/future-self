import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/features/goals/data/goals_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  const uid = 'user-1';
  late FakeFirebaseFirestore firestore;
  late GoalsRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(user);

    repository = GoalsRepository(
      FirebaseService(
        auth: auth,
        firestore: firestore,
        messaging: MockFirebaseMessaging(),
      ),
    );
  });

  Future<void> seedGoal(Goal goal) => firestore
      .collection('users')
      .doc(uid)
      .collection('goals')
      .doc(goal.id)
      .set(goal.toMap());

  Goal numericGoal({int totalXpEarned = 0}) => Goal(
        id: 'g1',
        userId: uid,
        category: Category.health,
        title: 'Kilo',
        metricTemplateId: 'health_weight',
        type: MetricType.numeric,
        direction: MetricDirection.decreasing,
        initialValue: 85,
        currentValue: 85,
        targetValue: 75,
        totalXpEarned: totalXpEarned,
        createdAt: DateTime(2026, 1, 1),
      );

  group('updateGoalProgress', () {
    test('hedef güncellenir, history yazılır, XP ve streak işlenir',
        () async {
      await seedGoal(numericGoal());

      await repository.updateGoalProgress('g1', newCurrentValue: 80);

      final goalDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .get();
      final goal = Goal.fromMap('g1', goalDoc.data()!);
      expect(goal.currentValue, 80);
      expect(goal.totalXpEarned, Goal.defaultXpReward);
      expect(goal.streakCount, 1);
      expect(goal.lastProgressUpdateAt, isNotNull);

      final history = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .collection('history')
          .get();
      expect(history.docs, hasLength(1));
      final entry = GoalHistoryEntry.fromMap(
        history.docs.single.id,
        history.docs.single.data(),
      );
      expect(entry.previousValue, 85);
      expect(entry.newValue, 80);

      final userDoc =
          await firestore.collection('users').doc(uid).get();
      final progress = UserProgress.fromMap(userDoc.data()!);
      expect(progress.totalXp, Goal.defaultXpReward);
      expect(progress.currentStreak, 1);
      expect(progress.lastActiveDate, isNotNull);
      // Freeze alanları da dokümana yazılır (ilk kayıtta ay yenilenir).
      expect(
        progress.freezesAvailable,
        UserProgress.monthlyFreezeAllowance,
      );
      expect(
        progress.lastFreezeRefillMonth,
        UserProgress.monthKey(DateTime.now()),
      );
    });

    test('ikinci güncelleme XP biriktirir, aynı gün streak artmaz',
        () async {
      await seedGoal(numericGoal());

      await repository.updateGoalProgress('g1', newCurrentValue: 82);
      await repository.updateGoalProgress('g1', newCurrentValue: 80);

      final goalDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .get();
      final goal = Goal.fromMap('g1', goalDoc.data()!);
      expect(goal.totalXpEarned, Goal.defaultXpReward * 2);
      expect(goal.streakCount, 1);

      final history = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .collection('history')
          .get();
      expect(history.docs, hasLength(2));

      final userDoc = await firestore.collection('users').doc(uid).get();
      expect(
        UserProgress.fromMap(userDoc.data()!).totalXp,
        Goal.defaultXpReward * 2,
      );
    });

    test('ilk güncelleme: lastProgressUpdateAt null iken streak 0 → 1 olur',
        () async {
      final goal = numericGoal();
      expect(goal.lastProgressUpdateAt, isNull);
      expect(goal.streakCount, 0);
      await seedGoal(goal);

      await repository.updateGoalProgress('g1', newCurrentValue: 84);

      final goalDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .get();
      expect(Goal.fromMap('g1', goalDoc.data()!).streakCount, 1);
    });

    test(
        'streak alanı olmadan bugün güncellenmiş eski hedefte de '
        'streak 1 olur', () async {
      // Streak özelliğinden önceki sürüm: lastProgressUpdateAt yazılmış
      // ama streakCount hep 0 kalmış.
      final legacyMap = numericGoal().toMap()
        ..['lastProgressUpdateAt'] = Timestamp.fromDate(DateTime.now())
        ..remove('streakCount')
        ..remove('totalXpEarned');
      await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .set(legacyMap);

      await repository.updateGoalProgress('g1', newCurrentValue: 80);

      final goalDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .get();
      expect(Goal.fromMap('g1', goalDoc.data()!).streakCount, 1);
    });

    test('justCompleted: sadece %100\'e İLK ulaşan güncellemede true',
        () async {
      await seedGoal(numericGoal()); // 85 → 75 hedefi

      expect(
        await repository.updateGoalProgress('g1', newCurrentValue: 80),
        isFalse, // %50
      );
      expect(
        await repository.updateGoalProgress('g1', newCurrentValue: 75),
        isTrue, // ilk kez %100
      );
      expect(
        await repository.updateGoalProgress('g1', newCurrentValue: 75),
        isFalse, // zaten %100'dü, tekrar kutlama yok
      );
    });

    test('deleteGoal history alt koleksiyonunu da siler', () async {
      await seedGoal(numericGoal());
      await repository.updateGoalProgress('g1', newCurrentValue: 80);

      await repository.deleteGoal('g1');

      final goalDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .get();
      expect(goalDoc.exists, isFalse);

      final history = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc('g1')
          .collection('history')
          .get();
      expect(history.docs, isEmpty);
    });
  });

  group('createSingleGoal', () {
    test('şablon + entry\'den hedef yazar (initial = current)', () async {
      await repository.createSingleGoal(
        template: MetricTemplates.byId('finance_savings'),
        entry: const UserMetricEntry(
          templateId: 'finance_savings',
          currentValue: '1000',
          targetValue: '50000',
        ),
      );

      final docs = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .get();
      final goal = Goal.fromMap(docs.docs.single.id, docs.docs.single.data());
      expect(goal.title, 'Birikim');
      expect(goal.category, Category.finance);
      expect(goal.initialValue, 1000);
      expect(goal.currentValue, 1000);
      expect(goal.targetValue, 50000);
      expect(goal.userId, uid);
    });

    test('tamamen boş entry StateError fırlatır, hiçbir şey yazılmaz',
        () async {
      expect(
        () => repository.createSingleGoal(
          template: MetricTemplates.byId('health_weight'),
          entry: const UserMetricEntry(templateId: 'health_weight'),
        ),
        throwsStateError,
      );
      final docs = await firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .get();
      expect(docs.docs, isEmpty);
    });
  });

  group('historyEntryFromUpdate', () {
    final timestamp = DateTime(2026, 7, 7);

    test('numeric: eski/yeni değer', () {
      final entry = GoalsRepository.historyEntryFromUpdate(
        numericGoal(),
        newCurrentValue: 80,
        timestamp: timestamp,
      );
      expect(entry.previousValue, 85);
      expect(entry.newValue, 80);
      expect(entry.previousLevel, isNull);
      expect(entry.note, isNull);
    });

    test('level: eski/yeni seviye', () {
      final goal = Goal(
        id: 'g2',
        userId: uid,
        category: Category.learning,
        title: 'Dil seviyesi',
        metricTemplateId: 'learning_language',
        type: MetricType.level,
        currentLevel: 'A2',
        targetLevel: 'C1',
        createdAt: DateTime(2026, 1, 1),
      );
      final entry = GoalsRepository.historyEntryFromUpdate(
        goal,
        newLevel: 'B1',
        timestamp: timestamp,
      );
      expect(entry.previousLevel, 'A2');
      expect(entry.newLevel, 'B1');
      expect(entry.newValue, isNull);
    });

    test('freeText: sadece not', () {
      final goal = Goal(
        id: 'g3',
        userId: uid,
        category: Category.personalGrowth,
        title: 'Meditasyon',
        metricTemplateId: 'growth_free',
        type: MetricType.freeText,
        targetText: 'Meditasyon',
        createdAt: DateTime(2026, 1, 1),
      );
      final entry = GoalsRepository.historyEntryFromUpdate(
        goal,
        timestamp: timestamp,
      );
      expect(entry.note, 'İlerleme kaydedildi');
      expect(entry.newValue, isNull);
      expect(entry.newLevel, isNull);
    });
  });
}
