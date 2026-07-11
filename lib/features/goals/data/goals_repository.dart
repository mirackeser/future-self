import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';
import '../../letters/data/letters_repository.dart';

/// Hedeflerin Firestore erişim katmanı: users/{uid}/goals.
class GoalsRepository {
  GoalsRepository(this._firebase, [this._lettersRepository]);

  final FirebaseService _firebase;

  /// Hedef tamamlanınca teslim edilecek mektupları kontrol etmek için
  /// (testlerde null bırakılabilir).
  final LettersRepository? _lettersRepository;

  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) =>
      _firebase.firestore.collection('users').doc(uid).collection('goals');

  String get _uid {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Hedef işlemleri için oturum açık olmalı.');
    }
    return user.uid;
  }

  Future<void> createGoal(Goal goal) =>
      _goalsRef(_uid).doc(goal.id).set(goal.toMap());

  Future<void> updateGoal(Goal goal) =>
      _goalsRef(_uid).doc(goal.id).set(goal.toMap());

  /// Hedefi ve history alt koleksiyonunu birlikte siler
  /// (Firestore alt koleksiyonları otomatik silmez).
  Future<void> deleteGoal(String goalId) async {
    final goalRef = _goalsRef(_uid).doc(goalId);
    final history = await goalRef.collection('history').get();

    final batch = _firebase.firestore.batch();
    for (final doc in history.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(goalRef);
    await batch.commit();
  }

  /// Hedefin ilerleme geçmişi, en yeni önce, son 20 kayıt.
  Stream<List<GoalHistoryEntry>> watchGoalHistory(String goalId) {
    return _goalsRef(_uid)
        .doc(goalId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              GoalHistoryEntry.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Kullanıcının hedefleri, en yeni önce.
  Stream<List<Goal>> watchGoals() {
    return _goalsRef(_uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs) Goal.fromMap(doc.id, doc.data()),
          ],
        );
  }

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firebase.firestore.collection('users').doc(uid);

  /// Kullanıcının XP/streak durumu; doküman yoksa varsayılanlar.
  Stream<UserProgress> watchUserProgress() {
    return _userRef(_uid).snapshots().map(
          (snapshot) => snapshot.exists
              ? UserProgress.fromMap(snapshot.data()!)
              : const UserProgress(),
        );
  }

  /// Hedefe ilerleme kaydeder: tipe göre değeri günceller,
  /// lastProgressUpdateAt'i şimdiye çeker; aynı transaction'da hedefin
  /// totalXpEarned/streakCount'u ile kullanıcının XP/streak'i güncellenir
  /// ve history alt koleksiyonuna kayıt yazılır.
  ///
  /// Hedef bu güncellemeyle İLK KEZ %100'e ulaştıysa true döner
  /// (kutlama tetiklemek için).
  Future<bool> updateGoalProgress(
    String goalId, {
    double? newCurrentValue,
    String? newLevel,
    String? newTargetText,
  }) async {
    final uid = _uid;
    final goalRef = _goalsRef(uid).doc(goalId);
    final userRef = _userRef(uid);
    final now = DateTime.now();

    final justCompleted =
        await _firebase.firestore.runTransaction<bool>((tx) async {
      final goalSnap = await tx.get(goalRef);
      if (!goalSnap.exists) {
        throw StateError('Hedef bulunamadı: $goalId');
      }
      final goal = Goal.fromMap(goalSnap.id, goalSnap.data()!);

      final userSnap = await tx.get(userRef);
      final progress = userSnap.exists
          ? UserProgress.fromMap(userSnap.data()!)
          : const UserProgress();

      final previousPercent = goal.progressPercent;

      final goalUpdate = <String, dynamic>{
        'lastProgressUpdateAt': Timestamp.fromDate(now),
        'totalXpEarned': goal.totalXpEarned + goal.xpReward,
        // Hedef bazlı seri dondurma hakkı kullanmaz (hak kullanıcı
        // seviyesinde tek kaynaktır, hedef başına yakılırsa çifte
        // harcama olur).
        'streakCount': UserProgress.nextStreak(
          currentStreak: goal.streakCount,
          lastActiveDate: goal.lastProgressUpdateAt,
          now: now,
        ).newStreak,
      };
      if (newCurrentValue != null) {
        goalUpdate['currentValue'] = newCurrentValue;
      }
      if (newLevel != null) {
        final levelIndex = MetricTemplates.byId(goal.metricTemplateId)
            .levelOptions
            .indexOf(newLevel);
        goalUpdate['currentLevel'] = newLevel;
        if (levelIndex >= 0) {
          goalUpdate['currentValue'] = levelIndex.toDouble();
        }
      }
      if (newTargetText != null) {
        goalUpdate['targetText'] = newTargetText;
      }
      tx.update(goalRef, goalUpdate);

      final historyEntry = historyEntryFromUpdate(
        goal,
        newCurrentValue: newCurrentValue,
        newLevel: newLevel,
        timestamp: now,
      );
      tx.set(goalRef.collection('history').doc(), historyEntry.toMap());

      // Ay değiştiyse önce dondurma hakları yenilenir, sonra streak
      // mantığı (gerekirse bir hak tüketerek) işletilir.
      final refilled = UserProgress.refillFreezesIfNeeded(progress, now);
      final streakResult = UserProgress.nextStreak(
        currentStreak: refilled.currentStreak,
        lastActiveDate: refilled.lastActiveDate,
        now: now,
        freezesAvailable: refilled.freezesAvailable,
      );
      final updatedProgress = refilled.copyWith(
        totalXp: refilled.totalXp + goal.xpReward,
        currentStreak: streakResult.newStreak,
        // Kişisel rekor: seri her güncellendiğinde max ile büyür.
        longestStreakEver: streakResult.newStreak > refilled.longestStreakEver
            ? streakResult.newStreak
            : refilled.longestStreakEver,
        lastActiveDate: now,
        freezesAvailable: streakResult.newFreezesAvailable,
      );
      tx.set(userRef, updatedProgress.toMap(), SetOptions(merge: true));

      // Bu güncellemeyle %100'e YENİ mi ulaşıldı?
      final updatedGoal = goal.copyWith(
        currentValue: (goalUpdate['currentValue'] as num?)?.toDouble() ??
            goal.currentValue,
        currentLevel: newLevel ?? goal.currentLevel,
      );
      return updatedGoal.progressPercent == 1.0 && previousPercent != 1.0;
    });

    // Hedef %100'e ulaştıysa bağlı Future Self mektuplarını teslim et.
    // Bildirim hatası ilerleme kaydını asla etkilememeli.
    try {
      await _lettersRepository?.checkGoalCompletionLetters(goalId);
    } catch (e, stackTrace) {
      log(
        'Hedef tamamlama mektupları kontrol edilemedi',
        name: 'GoalsRepository',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return justCompleted;
  }

  /// Dashboard'dan tek hedef ekleme (onboarding toplu akışının tekili).
  ///
  /// Aynı goalFromEntry dönüşümünü kullanır; entry tamamen boşsa
  /// StateError fırlatır (UI en az bir değer girilmesini zorlar).
  Future<void> createSingleGoal({
    required MetricTemplate template,
    required UserMetricEntry entry,
  }) async {
    final docRef = _goalsRef(_uid).doc();
    final goal = goalFromEntry(
      entry,
      userId: _uid,
      goalId: docRef.id,
      createdAt: DateTime.now(),
    );
    if (goal == null) {
      throw StateError('Hedef için en az bir değer girilmeli.');
    }
    await docRef.set(goal.toMap());
  }

  /// Onboarding'de girilen metrikleri hedeflere çevirip toplu yazar.
  ///
  /// Sadece seçili kategorilere ait ve en az bir değeri dolu entry'ler
  /// hedef olur; tamamen boş bırakılanlar atlanır.
  Future<void> createGoalsFromOnboarding(
    List<UserMetricEntry> entries,
    Set<Category> categories,
  ) async {
    final uid = _uid;
    final batch = _firebase.firestore.batch();
    final now = DateTime.now();
    var goalCount = 0;

    for (final entry in entries) {
      final template = MetricTemplates.byId(entry.templateId);
      if (!categories.contains(template.category)) continue;

      final docRef = _goalsRef(uid).doc();
      final goal = goalFromEntry(
        entry,
        userId: uid,
        goalId: docRef.id,
        createdAt: now,
      );
      if (goal == null) continue;

      batch.set(docRef, goal.toMap());
      goalCount++;
    }

    if (goalCount > 0) {
      await batch.commit();
    }
  }

  /// İlerleme güncellemesinin history kaydını üretir.
  ///
  /// Numeric'te eski/yeni değer, level'da eski/yeni seviye tutulur;
  /// freeText'te sadece not düşülür.
  @visibleForTesting
  static GoalHistoryEntry historyEntryFromUpdate(
    Goal goal, {
    double? newCurrentValue,
    String? newLevel,
    required DateTime timestamp,
  }) {
    if (newCurrentValue != null) {
      return GoalHistoryEntry(
        previousValue: goal.currentValue,
        newValue: newCurrentValue,
        timestamp: timestamp,
      );
    }
    if (newLevel != null) {
      return GoalHistoryEntry(
        previousLevel: goal.currentLevel,
        newLevel: newLevel,
        timestamp: timestamp,
      );
    }
    return GoalHistoryEntry(note: 'İlerleme kaydedildi', timestamp: timestamp);
  }

  /// Tek bir onboarding girişini hedefe çevirir; entry boşsa null.
  ///
  /// Level girişlerde seviye adları [Goal.currentLevel]/[Goal.targetLevel]'a,
  /// seviye indeksleri sayısal alanlara yazılır — böylece ilerleme yüzdesi
  /// sayısal hedeflerle aynı formülden çıkar.
  @visibleForTesting
  static Goal? goalFromEntry(
    UserMetricEntry entry, {
    required String userId,
    required String goalId,
    required DateTime createdAt,
  }) {
    if (entry.currentValue == null && entry.targetValue == null) return null;

    final template = MetricTemplates.byId(entry.templateId);

    switch (template.type) {
      case MetricType.numeric:
        final current = _parseNumber(entry.currentValue);
        return Goal(
          id: goalId,
          userId: userId,
          category: template.category,
          title: template.label,
          metricTemplateId: template.id,
          type: template.type,
          direction: template.direction,
          initialValue: current,
          currentValue: current,
          targetValue: _parseNumber(entry.targetValue),
          createdAt: createdAt,
        );

      case MetricType.level:
        final currentIndex = template.levelOptions.indexOf(
          entry.currentValue ?? '',
        );
        final targetIndex = template.levelOptions.indexOf(
          entry.targetValue ?? '',
        );
        return Goal(
          id: goalId,
          userId: userId,
          category: template.category,
          title: template.label,
          metricTemplateId: template.id,
          type: template.type,
          initialValue: currentIndex < 0 ? null : currentIndex.toDouble(),
          currentValue: currentIndex < 0 ? null : currentIndex.toDouble(),
          targetValue: targetIndex < 0 ? null : targetIndex.toDouble(),
          currentLevel: entry.currentValue,
          targetLevel: entry.targetValue,
          createdAt: createdAt,
        );

      case MetricType.freeText:
        final text = entry.targetValue ?? entry.currentValue;
        return Goal(
          id: goalId,
          userId: userId,
          category: template.category,
          title: text ?? template.label,
          metricTemplateId: template.id,
          type: template.type,
          targetText: text,
          createdAt: createdAt,
        );
    }
  }

  /// "75,5" gibi virgüllü girişleri de kabul eder.
  static double? _parseNumber(String? value) {
    if (value == null) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }
}

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository(
    ref.watch(firebaseServiceProvider),
    ref.watch(lettersRepositoryProvider),
  );
});
