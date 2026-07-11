import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';
import '../../chapters/domain/chapter_generator.dart' show isoWeekIdFor, mondayOf;
import '../domain/challenge_generator.dart';

/// Haftalık meydan okumalar: users/{uid}/weeklyChallenges/{weekId}.
class ChallengesRepository {
  ChallengesRepository(this._firebase);

  final FirebaseService _firebase;

  CollectionReference<Map<String, dynamic>> _challengesRef(String uid) =>
      _firebase.firestore
          .collection('users')
          .doc(uid)
          .collection('weeklyChallenges');

  String get _uid {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Challenge işlemleri için oturum açık olmalı.');
    }
    return user.uid;
  }

  /// Bu haftanın challenge'ı; doküman yoksa deterministik üretip yazar.
  Future<WeeklyChallenge> getOrCreateCurrentChallenge() async {
    final uid = _uid;
    final weekId = isoWeekIdFor(DateTime.now());
    final docRef = _challengesRef(uid).doc(weekId);

    final doc = await docRef.get();
    if (doc.exists) return WeeklyChallenge.fromMap(doc.id, doc.data()!);

    final challenge = pickChallengeForWeek(weekId, uid);
    await docRef.set(challenge.toMap());
    return challenge;
  }

  /// Bu haftanın challenge dokümanını canlı izler.
  Stream<WeeklyChallenge?> watchThisWeekChallenge() {
    final weekId = isoWeekIdFor(DateTime.now());
    return _challengesRef(_uid).doc(weekId).snapshots().map(
          (doc) => doc.exists
              ? WeeklyChallenge.fromMap(doc.id, doc.data()!)
              : null,
        );
  }

  /// Challenge tipine göre bu haftaki (pazartesi → şimdi) ilerleme.
  Future<int> computeCurrentProgress(WeeklyChallenge challenge) async {
    final uid = _uid;
    final weekStart = mondayOf(DateTime.now());

    switch (challenge.type) {
      case ChallengeType.threeDayUpdateStreak:
        final entries = await _weekHistoryEntries(uid, weekStart);
        final days = <DateTime>{
          for (final (_, entry) in entries)
            DateTime(
              entry.timestamp.year,
              entry.timestamp.month,
              entry.timestamp.day,
            ),
        };
        return days.length;

      case ChallengeType.twoGoalsProgress:
        final entries = await _weekHistoryEntries(uid, weekStart);
        return {for (final (goal, _) in entries) goal.id}.length;

      case ChallengeType.tenPercentOnAnyGoal:
        final entries = await _weekHistoryEntries(uid, weekStart);
        for (final (goal, entry) in entries) {
          final delta = entryProgressDelta(goal, entry);
          if (delta != null && delta >= 0.10) return 1;
        }
        return 0;

      case ChallengeType.addMissionNote:
        // Not dizisi sorgulanamaz; mission sayısı küçük, istemcide taranır.
        final missions = await _firebase.firestore
            .collection('users')
            .doc(uid)
            .collection('missions')
            .get();
        var noteCount = 0;
        for (final doc in missions.docs) {
          final mission = Mission.fromMap(doc.id, doc.data());
          noteCount += mission.notes
              .where((n) => !n.timestamp.isBefore(weekStart))
              .length;
        }
        return noteCount;

      case ChallengeType.answerReflection:
        final reflections = await _firebase.firestore
            .collection('users')
            .doc(uid)
            .collection('reflections')
            .where(
              'answeredAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
            )
            .get();
        return reflections.docs.length;

      case ChallengeType.commentOnLesson:
        // Tüm lesson'ları taramak yerine collection group: authorUid +
        // createdAt composite index'i ister (Console linki verir).
        final comments = await _firebase.firestore
            .collectionGroup('comments')
            .where('authorUid', isEqualTo: uid)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
            )
            .get();
        return comments.docs.length;
    }
  }

  /// Bu haftaki tüm hedeflerin history kayıtları, (goal, entry) olarak.
  Future<List<(Goal, GoalHistoryEntry)>> _weekHistoryEntries(
    String uid,
    DateTime weekStart,
  ) async {
    final goalsSnap = await _firebase.firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .get();

    final result = <(Goal, GoalHistoryEntry)>[];
    for (final goalDoc in goalsSnap.docs) {
      final goal = Goal.fromMap(goalDoc.id, goalDoc.data());
      final historySnap = await goalDoc.reference
          .collection('history')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
          )
          .get();
      for (final doc in historySnap.docs) {
        result.add((goal, GoalHistoryEntry.fromMap(doc.id, doc.data())));
      }
    }
    return result;
  }

  /// Hedef tutturulduysa ödülü bir kez verir.
  ///
  /// Transaction dokümanı taze okuyup isClaimed'i kontrol eder; yarış
  /// durumunda bile çifte XP verilmez. Ödül verildiyse true döner.
  Future<bool> claimIfCompleted(
    WeeklyChallenge challenge,
    int currentProgress,
  ) async {
    if (challenge.isClaimed) return false;
    if (currentProgress < challenge.targetValue) return false;

    final uid = _uid;
    final challengeRef = _challengesRef(uid).doc(challenge.id);
    final userRef = _firebase.firestore.collection('users').doc(uid);

    return _firebase.firestore.runTransaction((tx) async {
      final freshDoc = await tx.get(challengeRef);
      if (!freshDoc.exists) return false;
      final fresh = WeeklyChallenge.fromMap(freshDoc.id, freshDoc.data()!);
      if (fresh.isClaimed) return false;

      final userDoc = await tx.get(userRef);
      final progress = userDoc.exists
          ? UserProgress.fromMap(userDoc.data()!)
          : const UserProgress();

      tx.update(challengeRef, {'isClaimed': true});
      tx.set(
        userRef,
        progress.copyWith(totalXp: progress.totalXp + fresh.xpReward).toMap(),
        SetOptions(merge: true),
      );
      return true;
    });
  }
}

final challengesRepositoryProvider = Provider<ChallengesRepository>((ref) {
  return ChallengesRepository(ref.watch(firebaseServiceProvider));
});
