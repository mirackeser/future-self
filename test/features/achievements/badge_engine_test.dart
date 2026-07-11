import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/achievements/domain/badge_engine.dart';

Goal buildGoal(
  String id, {
  double? currentValue = 85,
  DateTime? lastProgressUpdateAt,
}) {
  return Goal(
    id: id,
    userId: 'u1',
    category: Category.health,
    title: id,
    metricTemplateId: 'health_weight',
    type: MetricType.numeric,
    initialValue: 85,
    currentValue: currentValue,
    targetValue: 75,
    createdAt: DateTime(2026, 1, 1),
    lastProgressUpdateAt: lastProgressUpdateAt,
  );
}

Goal completedGoal(String id) => buildGoal(id, currentValue: 75);

Mission buildMission(String id, {bool isCompleted = false}) => Mission(
      id: id,
      userId: 'u1',
      title: id,
      createdAt: DateTime(2026, 1, 1),
      isCompleted: isCompleted,
    );

Lesson buildLesson(String id, {int likeCount = 0}) => Lesson(
      id: id,
      authorUid: 'u1',
      text: 't',
      category: Category.career,
      createdAt: DateTime(2026, 1, 1),
      likeCount: likeCount,
    );

void main() {
  test('sıfırdan kullanıcı: hiçbir rozet açık değil', () {
    final unlocked =
        evaluateUnlockedBadges(const [], const UserProgress(), const [], const [], 0);
    expect(unlocked, isEmpty);
  });

  test('streak rozetleri longestStreakEver dahil en yüksekten açılır', () {
    final unlocked = evaluateUnlockedBadges(
      const [],
      const UserProgress(currentStreak: 3, longestStreakEver: 35),
      const [],
      const [],
      0,
    );
    expect(unlocked, containsAll(['streak_7', 'streak_30']));
    expect(unlocked, isNot(contains('streak_100')));
  });

  test('hedef rozetleri: eklendi / tamamlandı sayıları', () {
    final goals = [
      completedGoal('g1'),
      completedGoal('g2'),
      completedGoal('g3'),
      completedGoal('g4'),
      completedGoal('g5'),
      buildGoal('g6'), // devam ediyor
    ];
    final unlocked =
        evaluateUnlockedBadges(goals, const UserProgress(), const [], const [], 0);

    expect(
      unlocked,
      containsAll(
          ['goal_first_added', 'goal_first_completed', 'goals_5_completed']),
    );
    expect(unlocked, isNot(contains('goals_10_completed')));
  });

  test('mission ve lessons rozetleri', () {
    final unlocked = evaluateUnlockedBadges(
      const [],
      const UserProgress(),
      [buildMission('m1', isCompleted: true)],
      [buildLesson('l1', likeCount: 62)],
      3,
    );

    expect(
      unlocked,
      containsAll([
        'mission_first_added',
        'mission_first_completed',
        'lesson_first_shared',
        'comment_first',
        'lesson_50_likes',
      ]),
    );
    expect(unlocked, isNot(contains('missions_5_completed')));
  });

  test('Geri Dönüş: seri kırılıp 7+ güne yeniden çıkılmış olmalı', () {
    // Rekor 20, mevcut 9 → arada kırılma var, yeniden 7+ → açık.
    expect(
      evaluateUnlockedBadges(
        const [],
        const UserProgress(currentStreak: 9, longestStreakEver: 20),
        const [],
        const [],
        0,
      ),
      contains('comeback'),
    );
    // Hiç kırılmamış (rekor == mevcut) → kapalı.
    expect(
      evaluateUnlockedBadges(
        const [],
        const UserProgress(currentStreak: 9, longestStreakEver: 9),
        const [],
        const [],
        0,
      ),
      isNot(contains('comeback')),
    );
    // Kırılmış ama henüz 7'ye çıkmamış → kapalı.
    expect(
      evaluateUnlockedBadges(
        const [],
        const UserProgress(currentStreak: 4, longestStreakEver: 20),
        const [],
        const [],
        0,
      ),
      isNot(contains('comeback')),
    );
  });

  test('Erken Kalkan: 05:00-08:00 arası güncelleme', () {
    expect(
      evaluateUnlockedBadges(
        [buildGoal('g1', lastProgressUpdateAt: DateTime(2026, 7, 9, 6, 30))],
        const UserProgress(),
        const [],
        const [],
        0,
      ),
      contains('early_bird'),
    );
    expect(
      evaluateUnlockedBadges(
        [buildGoal('g1', lastProgressUpdateAt: DateTime(2026, 7, 9, 14))],
        const UserProgress(),
        const [],
        const [],
        0,
      ),
      isNot(contains('early_bird')),
    );
  });

  test('level rozetleri', () {
    // L10 kümülatif eşiği aşan XP (L10'a giriş ~2125 XP).
    const progress = UserProgress(totalXp: 2200);
    final unlocked =
        evaluateUnlockedBadges(const [], progress, const [], const [], 0);
    expect(progress.level, greaterThanOrEqualTo(10));
    expect(unlocked, contains('level_10'));
    expect(unlocked, isNot(contains('level_25')));
  });

  test('kataloğun tüm rozetleri değerlendirmede karşılık buluyor', () {
    // Maksimalist senaryo: her şey açık.
    final goals = [
      for (var i = 0; i < 10; i++) completedGoal('g$i'),
      buildGoal('early', lastProgressUpdateAt: DateTime(2026, 7, 9, 6)),
    ];
    final missions = [
      for (var i = 0; i < 5; i++) buildMission('m$i', isCompleted: true),
    ];
    final unlocked = evaluateUnlockedBadges(
      goals,
      const UserProgress(
        totalXp: 20000,
        currentStreak: 100,
        longestStreakEver: 150,
      ),
      missions,
      [buildLesson('l1', likeCount: 100)],
      5,
    );

    expect(unlocked, BadgeCatalog.all.map((b) => b.id).toSet());
  });
}
