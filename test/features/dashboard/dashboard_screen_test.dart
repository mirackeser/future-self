import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/dashboard/presentation/dashboard_screen.dart';

Goal buildGoal({
  required String id,
  MetricType type = MetricType.numeric,
  double? initialValue,
  double? currentValue,
  double? targetValue,
  DateTime? lastProgressUpdateAt,
}) {
  return Goal(
    id: id,
    userId: 'u1',
    category: Category.health,
    title: id,
    metricTemplateId: 'health_weight',
    type: type,
    initialValue: initialValue,
    currentValue: currentValue,
    targetValue: targetValue,
    createdAt: DateTime(2026, 1, 1),
    lastProgressUpdateAt: lastProgressUpdateAt,
  );
}

Goal activeGoal(String id, {DateTime? lastProgressUpdateAt}) => buildGoal(
      id: id,
      initialValue: 0,
      currentValue: 50,
      targetValue: 100,
      lastProgressUpdateAt: lastProgressUpdateAt,
    );

Goal completedGoal(String id, {DateTime? lastProgressUpdateAt}) => buildGoal(
      id: id,
      initialValue: 0,
      currentValue: 100,
      targetValue: 100,
      lastProgressUpdateAt: lastProgressUpdateAt,
    );

void main() {
  group('topActiveGoals', () {
    test('tamamlanan (%100) hedefler listelenmez', () {
      final goals = [
        completedGoal('done1', lastProgressUpdateAt: DateTime(2026, 1, 2)),
        activeGoal('a1', lastProgressUpdateAt: DateTime(2026, 1, 5)),
        completedGoal('done2'),
        activeGoal('a2', lastProgressUpdateAt: DateTime(2026, 1, 3)),
      ];

      final top = topActiveGoals(goals);

      expect(top.map((g) => g.id), isNot(contains('done1')));
      expect(top.map((g) => g.id), isNot(contains('done2')));
      expect(top.map((g) => g.id), containsAll(['a1', 'a2']));
    });

    test('en uzun süredir güncellenmeyen önce, hiç güncellenmeyen en önce',
        () {
      final goals = [
        activeGoal('recent', lastProgressUpdateAt: DateTime(2026, 1, 9)),
        activeGoal('old', lastProgressUpdateAt: DateTime(2026, 1, 2)),
        activeGoal('never'),
      ];

      final top = topActiveGoals(goals);

      expect(top.map((g) => g.id).toList(), ['never', 'old', 'recent']);
    });

    test('en fazla 3 hedef döner ve tamamlananlar limiti tüketmez', () {
      final goals = [
        completedGoal('done', lastProgressUpdateAt: DateTime(2026, 1, 1)),
        for (var i = 0; i < 4; i++)
          activeGoal('a$i', lastProgressUpdateAt: DateTime(2026, 1, 2 + i)),
      ];

      final top = topActiveGoals(goals);

      expect(top, hasLength(3));
      expect(top.map((g) => g.id).toList(), ['a0', 'a1', 'a2']);
    });

    test('freeText hedef (yüzdesiz) her zaman aktif sayılır', () {
      final goals = [
        buildGoal(id: 'free', type: MetricType.freeText),
        completedGoal('done'),
      ];

      final top = topActiveGoals(goals);

      expect(top.map((g) => g.id).toList(), ['free']);
    });
  });

  group('completedGoalsCount', () {
    test('sadece %100 hedefleri sayar; freeText sayılmaz', () {
      final goals = [
        completedGoal('done1'),
        completedGoal('done2'),
        activeGoal('a1'),
        buildGoal(id: 'free', type: MetricType.freeText),
      ];

      expect(completedGoalsCount(goals), 2);
    });
  });
}
