import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/achievements/domain/personal_records.dart';

final _now = DateTime(2026, 7, 9);

Goal buildGoal(
  String id, {
  String? title,
  double? currentValue,
  DateTime? createdAt,
}) {
  return Goal(
    id: id,
    userId: 'u1',
    category: Category.health,
    title: title ?? id,
    metricTemplateId: 'health_weight',
    type: MetricType.numeric,
    initialValue: 85,
    currentValue: currentValue ?? 85,
    targetValue: 75,
    createdAt: createdAt ?? _now.subtract(const Duration(days: 10)),
  );
}

void main() {
  test('boş veride sıfır rekorlar', () {
    final records =
        computeRecords(const [], const UserProgress(), const [], now: _now);

    expect(records.longestStreakEver, 0);
    expect(records.totalXp, 0);
    expect(records.completedGoalsCount, 0);
    expect(records.completedMissionsCount, 0);
    expect(records.fastestProgressingGoal, isNull);
  });

  test('en uzun seri: rekor ve mevcut serinin büyüğü', () {
    expect(
      computeRecords(
        const [],
        const UserProgress(currentStreak: 12, longestStreakEver: 8),
        const [],
        now: _now,
      ).longestStreakEver,
      12,
      reason: 'mevcut seri rekoru geçtiyse o gösterilmeli',
    );
    expect(
      computeRecords(
        const [],
        const UserProgress(currentStreak: 3, longestStreakEver: 40),
        const [],
        now: _now,
      ).longestStreakEver,
      40,
    );
  });

  test('tamamlanan hedef/mission sayıları ve toplam XP', () {
    final records = computeRecords(
      [
        buildGoal('g1', currentValue: 75), // %100
        buildGoal('g2', currentValue: 80), // %50
      ],
      const UserProgress(totalXp: 1250),
      [
        Mission(
          id: 'm1',
          userId: 'u1',
          title: 'm1',
          createdAt: _now,
          isCompleted: true,
        ),
        Mission(id: 'm2', userId: 'u1', title: 'm2', createdAt: _now),
      ],
      now: _now,
    );

    expect(records.completedGoalsCount, 1);
    expect(records.completedMissionsCount, 1);
    expect(records.totalXp, 1250);
  });

  test('en hızlı ilerleyen: yüzde/gün oranı en yüksek hedef', () {
    final records = computeRecords(
      [
        // %50, 10 günde → 0.05/gün
        buildGoal('slow', title: 'Yavaş', currentValue: 80),
        // %50, 2 günde → 0.25/gün
        buildGoal(
          'fast',
          title: 'Hızlı',
          currentValue: 80,
          createdAt: _now.subtract(const Duration(days: 2)),
        ),
        // İlerlemesiz hedef adaylığa giremez.
        buildGoal('idle', title: 'Boş', currentValue: 85),
      ],
      const UserProgress(),
      const [],
      now: _now,
    );

    expect(records.fastestProgressingGoal?.title, 'Hızlı');
  });
}
