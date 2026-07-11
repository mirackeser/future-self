import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/goals/data/goals_repository.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1);

  Goal? fromEntry(UserMetricEntry entry) => GoalsRepository.goalFromEntry(
        entry,
        userId: 'u1',
        goalId: 'g1',
        createdAt: createdAt,
      );

  group('goalFromEntry', () {
    test('tamamen boş entry hedef olmuyor', () {
      final goal = fromEntry(
        const UserMetricEntry(templateId: 'health_weight'),
      );
      expect(goal, isNull);
    });

    test('numeric: değerler parse edilip initial=current oluyor', () {
      final goal = fromEntry(
        const UserMetricEntry(
          templateId: 'health_weight',
          currentValue: '85,5',
          targetValue: '75',
        ),
      );

      expect(goal, isNotNull);
      expect(goal!.type, MetricType.numeric);
      expect(goal.direction, MetricDirection.decreasing);
      expect(goal.initialValue, 85.5);
      expect(goal.currentValue, 85.5);
      expect(goal.targetValue, 75);
      expect(goal.title, 'Kilo');
      expect(goal.category, Category.health);
    });

    test('level: seviye adları saklanıp indeksler sayısal alanlara yazılıyor',
        () {
      final goal = fromEntry(
        const UserMetricEntry(
          templateId: 'learning_language',
          currentValue: 'A2',
          targetValue: 'C1',
        ),
      );

      expect(goal, isNotNull);
      expect(goal!.currentLevel, 'A2');
      expect(goal.targetLevel, 'C1');
      expect(goal.initialValue, 1); // A1=0, A2=1
      expect(goal.targetValue, 4); // C1=4
      expect(goal.progressPercent, 0.0);
    });

    test('freeText: metin hem başlık hem targetText oluyor, yüzde yok', () {
      final goal = fromEntry(
        const UserMetricEntry(
          templateId: 'growth_free',
          targetValue: 'Her gün 10 dakika meditasyon',
        ),
      );

      expect(goal, isNotNull);
      expect(goal!.title, 'Her gün 10 dakika meditasyon');
      expect(goal.targetText, 'Her gün 10 dakika meditasyon');
      expect(goal.progressPercent, isNull);
    });

    test('varsayılan xpReward ve streak değerleri', () {
      final goal = fromEntry(
        const UserMetricEntry(
          templateId: 'finance_savings',
          targetValue: '100000',
        ),
      );

      expect(goal!.xpReward, Goal.defaultXpReward);
      expect(goal.streakCount, 0);
      expect(goal.lastProgressUpdateAt, isNull);
    });
  });
}
