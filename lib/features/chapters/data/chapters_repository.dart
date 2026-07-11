import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';
import '../domain/chapter_generator.dart';

/// Haftalık bölümlerin Firestore katmanı: users/{uid}/chapters/{weekId}.
class ChaptersRepository {
  ChaptersRepository(this._firebase);

  final FirebaseService _firebase;

  CollectionReference<Map<String, dynamic>> _chaptersRef(String uid) =>
      _firebase.firestore.collection('users').doc(uid).collection('chapters');

  /// Bölümler, en yeni hafta önce.
  Stream<List<Chapter>> watchChapters() {
    final user = _firebase.currentUser;
    if (user == null) return Stream.value(const []);
    return _chaptersRef(user.uid)
        .orderBy('weekNumber', descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              Chapter.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Son tamamlanmış hafta (önceki ISO haftası) için bölüm yoksa üretip
  /// kaydeder. Arka planda çağrılır; hata uygulamayı asla etkilemez.
  Future<void> generateAndSaveWeeklyChapterIfNeeded() async {
    try {
      final user = _firebase.currentUser;
      if (user == null) return;
      final uid = user.uid;

      final now = DateTime.now();
      final weekStart = mondayOf(now).subtract(const Duration(days: 7));
      final weekEndExclusive = weekStart.add(const Duration(days: 7));
      final weekId = isoWeekIdFor(weekStart);

      final docRef = _chaptersRef(uid).doc(weekId);
      if ((await docRef.get()).exists) return;

      // Hesap o hafta bittikten sonra açıldıysa anlatılacak hafta yok.
      final creation = user.metadata.creationTime;
      if (creation != null &&
          !mondayOf(creation).isBefore(weekEndExclusive)) {
        return;
      }
      final weekNumber = creation == null
          ? 1
          : (weekStart.difference(mondayOf(creation)).inDays ~/ 7) + 1;
      if (weekNumber < 1) return;

      // Haftalık veriyi topla.
      final goalsSnap = await _firebase.firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .get();
      final goals = [
        for (final doc in goalsSnap.docs) Goal.fromMap(doc.id, doc.data()),
      ];

      final weekHistoryByGoal = <String, List<GoalHistoryEntry>>{};
      final allTimestamps = <DateTime>[];
      var xpGained = 0;
      for (final goal in goals) {
        final historySnap = await goalsSnap.docs
            .firstWhere((d) => d.id == goal.id)
            .reference
            .collection('history')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
              isLessThan: Timestamp.fromDate(weekEndExclusive),
            )
            .get();
        if (historySnap.docs.isEmpty) continue;
        final entries = [
          for (final doc in historySnap.docs)
            GoalHistoryEntry.fromMap(doc.id, doc.data()),
        ];
        weekHistoryByGoal[goal.id] = entries;
        allTimestamps.addAll(entries.map((e) => e.timestamp));
        // Her ilerleme kaydı bir kez xpReward kazandırır.
        xpGained += entries.length * goal.xpReward;
      }

      final missionsSnap = await _firebase.firestore
          .collection('users')
          .doc(uid)
          .collection('missions')
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
            isLessThan: Timestamp.fromDate(weekEndExclusive),
          )
          .get();

      final chapter = generateChapter(
        weekNumber: weekNumber,
        startDate: weekStart,
        endDate: weekStart.add(const Duration(days: 6)),
        weekHistoryByGoal: weekHistoryByGoal,
        goals: goals,
        xpGainedThisWeek: xpGained,
        longestStreakThisWeek: longestConsecutiveActivityDays(allTimestamps),
        missionsCompletedThisWeek: missionsSnap.docs.length,
      );
      await docRef.set(chapter.toMap());
    } catch (e, stackTrace) {
      log(
        'Haftalık bölüm üretilemedi',
        name: 'ChaptersRepository',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

final chaptersRepositoryProvider = Provider<ChaptersRepository>((ref) {
  return ChaptersRepository(ref.watch(firebaseServiceProvider));
});
