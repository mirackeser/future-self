import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/features/challenges/data/challenges_repository.dart';
import 'package:future_self/features/chapters/domain/chapter_generator.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  const uid = 'user-1';
  late FakeFirebaseFirestore firestore;
  late ChallengesRepository repository;
  final weekStart = mondayOf(DateTime.now());

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(user);

    repository = ChallengesRepository(
      FirebaseService(
        auth: auth,
        firestore: firestore,
        messaging: MockFirebaseMessaging(),
      ),
    );
  });

  WeeklyChallenge challengeOf(ChallengeType type) => WeeklyChallenge(
        id: isoWeekIdFor(DateTime.now()),
        type: type,
        targetValue: 2,
        xpReward: 60,
      );

  Future<void> seedGoalWithHistory(
    String goalId,
    List<DateTime> timestamps, {
    double prev = 85,
    double next = 84.5,
  }) async {
    final goal = Goal(
      id: goalId,
      userId: uid,
      category: Category.health,
      title: goalId,
      metricTemplateId: 'health_weight',
      type: MetricType.numeric,
      initialValue: 85,
      currentValue: next,
      targetValue: 75,
      createdAt: DateTime(2026, 1, 1),
    );
    final goalRef = firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId);
    await goalRef.set(goal.toMap());
    for (final ts in timestamps) {
      await goalRef.collection('history').add(
            GoalHistoryEntry(previousValue: prev, newValue: next, timestamp: ts)
                .toMap(),
          );
    }
  }

  test('getOrCreateCurrentChallenge deterministik oluşturur, ikinci '
      'çağrıda aynısını döner', () async {
    final first = await repository.getOrCreateCurrentChallenge();
    final second = await repository.getOrCreateCurrentChallenge();

    expect(first.id, isoWeekIdFor(DateTime.now()));
    expect(second.type, first.type);
    final docs = await firestore
        .collection('users')
        .doc(uid)
        .collection('weeklyChallenges')
        .get();
    expect(docs.docs, hasLength(1));
  });

  group('computeCurrentProgress', () {
    test('threeDayUpdateStreak: farklı gün sayısı (hafta öncesi sayılmaz)',
        () async {
      await seedGoalWithHistory('g1', [
        weekStart.add(const Duration(hours: 9)),
        weekStart.add(const Duration(hours: 15)), // aynı gün
        weekStart.add(const Duration(days: 1)),
        weekStart.subtract(const Duration(days: 2)), // geçen hafta
      ]);

      final progress = await repository.computeCurrentProgress(
        challengeOf(ChallengeType.threeDayUpdateStreak),
      );
      expect(progress, 2);
    });

    test('twoGoalsProgress: farklı hedef sayısı', () async {
      await seedGoalWithHistory('g1', [weekStart]);
      await seedGoalWithHistory('g2', [
        weekStart.add(const Duration(days: 1)),
        weekStart.add(const Duration(days: 2)),
      ]);

      final progress = await repository.computeCurrentProgress(
        challengeOf(ChallengeType.twoGoalsProgress),
      );
      expect(progress, 2);
    });

    test('tenPercentOnAnyGoal: tek kayıtta %10 sıçrama arar', () async {
      // 85→84.5: %5 — yetmez.
      await seedGoalWithHistory('g1', [weekStart]);
      expect(
        await repository.computeCurrentProgress(
          challengeOf(ChallengeType.tenPercentOnAnyGoal),
        ),
        0,
      );

      // 85→83.5: %15 — yeter.
      await seedGoalWithHistory(
        'g2',
        [weekStart.add(const Duration(days: 1))],
        prev: 85,
        next: 83.5,
      );
      expect(
        await repository.computeCurrentProgress(
          challengeOf(ChallengeType.tenPercentOnAnyGoal),
        ),
        1,
      );
    });

    test('addMissionNote: bu haftaki not sayısı', () async {
      final mission = Mission(
        id: 'm1',
        userId: uid,
        title: 'Japonya',
        createdAt: DateTime(2026, 1, 1),
        notes: [
          MissionNote(text: 'eski', timestamp: weekStart.subtract(const Duration(days: 3))),
          MissionNote(text: 'yeni', timestamp: weekStart.add(const Duration(days: 1))),
        ],
      );
      await firestore
          .collection('users')
          .doc(uid)
          .collection('missions')
          .doc('m1')
          .set(mission.toMap());

      final progress = await repository.computeCurrentProgress(
        challengeOf(ChallengeType.addMissionNote),
      );
      expect(progress, 1);
    });

    test('answerReflection: bu haftaki yanıt sayısı', () async {
      final ref = firestore
          .collection('users')
          .doc(uid)
          .collection('reflections');
      await ref.doc('2026-01-05').set({
        'question': 'q',
        'answer': 'a',
        'answeredAt':
            Timestamp.fromDate(weekStart.subtract(const Duration(days: 30))),
      });
      await ref.doc('bugun').set({
        'question': 'q',
        'answer': 'a',
        'answeredAt': Timestamp.fromDate(weekStart.add(const Duration(days: 1))),
      });

      final progress = await repository.computeCurrentProgress(
        challengeOf(ChallengeType.answerReflection),
      );
      expect(progress, 1);
    });

    test('commentOnLesson: kullanıcının bu haftaki yorumları', () async {
      final commentsRef =
          firestore.collection('lessons').doc('l1').collection('comments');
      await commentsRef.add({
        'lessonId': 'l1',
        'authorUid': uid,
        'text': 'benim yorumum',
        'createdAt': Timestamp.fromDate(weekStart.add(const Duration(days: 1))),
        'likeCount': 0,
        'reportCount': 0,
      });
      await commentsRef.add({
        'lessonId': 'l1',
        'authorUid': 'baskasi',
        'text': 'başkasının yorumu',
        'createdAt': Timestamp.fromDate(weekStart.add(const Duration(days: 1))),
        'likeCount': 0,
        'reportCount': 0,
      });
      // fake_cloud_firestore collection group ısınma sorgusu (bilinen quirk).
      await firestore.collectionGroup('comments').get();

      final progress = await repository.computeCurrentProgress(
        challengeOf(ChallengeType.commentOnLesson),
      );
      expect(progress, 1);
    });
  });

  group('claimIfCompleted', () {
    test('hedef tutunca bir kez ödüllendirir', () async {
      final challenge = await repository.getOrCreateCurrentChallenge();

      final claimed = await repository.claimIfCompleted(
        challenge,
        challenge.targetValue,
      );
      expect(claimed, isTrue);

      final userDoc =
          await firestore.collection('users').doc(uid).get();
      expect(
        UserProgress.fromMap(userDoc.data()!).totalXp,
        challenge.xpReward,
      );

      // İkinci deneme: doküman artık isClaimed, tekrar XP yok.
      final again = await repository.claimIfCompleted(
        challenge, // eski (isClaimed=false görünen) nesneyle bile
        challenge.targetValue,
      );
      expect(again, isFalse);
      final userDoc2 =
          await firestore.collection('users').doc(uid).get();
      expect(
        UserProgress.fromMap(userDoc2.data()!).totalXp,
        challenge.xpReward,
      );
    });

    test('ilerleme yetersizse ödül verilmez', () async {
      final challenge = await repository.getOrCreateCurrentChallenge();

      final claimed = await repository.claimIfCompleted(
        challenge,
        challenge.targetValue - 1,
      );

      expect(claimed, isFalse);
      final userDoc = await firestore.collection('users').doc(uid).get();
      expect(userDoc.exists, isFalse);
    });
  });
}
