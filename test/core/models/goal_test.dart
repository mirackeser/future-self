import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';

Goal buildGoal({
  MetricType type = MetricType.numeric,
  MetricDirection? direction,
  double? initialValue,
  double? currentValue,
  double? targetValue,
  DateTime? createdAt,
}) {
  return Goal(
    id: 'g1',
    userId: 'u1',
    category: Category.health,
    title: 'Test',
    metricTemplateId: 'health_weight',
    type: type,
    direction: direction,
    initialValue: initialValue,
    currentValue: currentValue,
    targetValue: targetValue,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  group('progressPercent', () {
    test('increasing: yarı yolda 0.5', () {
      final goal = buildGoal(
        direction: MetricDirection.increasing,
        initialValue: 1000,
        currentValue: 3000,
        targetValue: 5000,
      );
      expect(goal.progressPercent, closeTo(0.5, 0.0001));
    });

    test('decreasing: 85→75 hedefinde 80 iken 0.5', () {
      final goal = buildGoal(
        direction: MetricDirection.decreasing,
        initialValue: 85,
        currentValue: 80,
        targetValue: 75,
      );
      expect(goal.progressPercent, closeTo(0.5, 0.0001));
    });

    test('decreasing: yanlış yöne gidince 0\'a clamp', () {
      final goal = buildGoal(
        direction: MetricDirection.decreasing,
        initialValue: 85,
        currentValue: 90,
        targetValue: 75,
      );
      expect(goal.progressPercent, 0.0);
    });

    test('hedefi aşınca 1.0\'a clamp (iki yönde de)', () {
      final increasing = buildGoal(
        direction: MetricDirection.increasing,
        initialValue: 0,
        currentValue: 120,
        targetValue: 100,
      );
      final decreasing = buildGoal(
        direction: MetricDirection.decreasing,
        initialValue: 85,
        currentValue: 70,
        targetValue: 75,
      );
      expect(increasing.progressPercent, 1.0);
      expect(decreasing.progressPercent, 1.0);
    });

    test('başlangıç == hedef ise 1.0', () {
      final goal = buildGoal(
        direction: MetricDirection.increasing,
        initialValue: 75,
        currentValue: 75,
        targetValue: 75,
      );
      expect(goal.progressPercent, 1.0);
    });

    test('freeText hedefte null', () {
      final goal = buildGoal(type: MetricType.freeText);
      expect(goal.progressPercent, isNull);
    });

    test('eksik değer varsa null', () {
      final goal = buildGoal(
        direction: MetricDirection.increasing,
        initialValue: 0,
        currentValue: 50,
        targetValue: null,
      );
      expect(goal.progressPercent, isNull);
    });
  });

  group('estimatedCompletion', () {
    test('10 günde %50 ilerleme → ~10 gün sonra biter', () {
      final createdAt = DateTime(2026, 1, 1);
      final now = DateTime(2026, 1, 11);
      final goal = buildGoal(
        direction: MetricDirection.increasing,
        initialValue: 0,
        currentValue: 50,
        targetValue: 100,
        createdAt: createdAt,
      );

      expect(
        goal.estimatedCompletion(now: now),
        DateTime(2026, 1, 21),
      );
    });

    test('ilerleme yoksa tahmin de yok', () {
      final goal = buildGoal(
        direction: MetricDirection.increasing,
        initialValue: 0,
        currentValue: 0,
        targetValue: 100,
      );
      expect(goal.estimatedCompletion(now: DateTime(2026, 1, 11)), isNull);
    });

    test('tamamlanmış hedef şimdiyi döner', () {
      final goal = buildGoal(
        direction: MetricDirection.increasing,
        initialValue: 0,
        currentValue: 100,
        targetValue: 100,
      );
      final now = DateTime(2026, 1, 11);
      expect(goal.estimatedCompletion(now: now), now);
    });
  });
}
