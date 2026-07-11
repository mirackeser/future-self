import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:future_self/l10n/app_localizations.dart';

// Pure fonksiyonlar artık l10n alıyor; test Türkçe locale sağlar.
final l10n = lookupAppLocalizations(const Locale('tr'));

Goal buildGoal({
  String title = 'Kilo',
  String templateId = 'health_weight',
  MetricType type = MetricType.numeric,
  double? initialValue,
  double? currentValue,
  int streakCount = 0,
  int totalXpEarned = 0,
}) {
  return Goal(
    id: 'g1',
    userId: 'u1',
    category: Category.health,
    title: title,
    metricTemplateId: templateId,
    type: type,
    initialValue: initialValue,
    currentValue: currentValue,
    streakCount: streakCount,
    totalXpEarned: totalXpEarned,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('deleteGoalDialogTitle', () {
    test('streak varsa gün sayısını vurgular', () {
      expect(
        deleteGoalDialogTitle(l10n, buildGoal(streakCount: 7)),
        '7 günlük serini bırakmak üzeresin',
      );
    });

    test('streak yoksa genel başlık', () {
      expect(
        deleteGoalDialogTitle(l10n, buildGoal(streakCount: 0)),
        'İlerlemeni bırakmak üzeresin',
      );
    });
  });

  group('deleteGoalDialogMessage', () {
    test('numeric: değerler birimle ve XP ile anlatılır', () {
      final message = deleteGoalDialogMessage(
        l10n,
        buildGoal(
          initialValue: 85,
          currentValue: 80,
          totalXpEarned: 150,
        ),
      );
      expect(
        message,
        "'Kilo' hedefinde 85 kg'den 80 kg'ye kadar geldin ve 150 XP "
        'kazandın. Bu hedefi silersen bu ilerleme geçmişi de silinir.',
      );
    });

    test('level: indeksler seviye adına çevrilir', () {
      final message = deleteGoalDialogMessage(
        l10n,
        buildGoal(
          title: 'Dil seviyesi',
          templateId: 'learning_language',
          type: MetricType.level,
          initialValue: 1, // A2
          currentValue: 2, // B1
          totalXpEarned: 100,
        ),
      );
      expect(message, contains("A2'den B1'ye kadar geldin"));
      expect(message, contains('100 XP'));
    });

    test('freeText: değer yerine sadece XP vurgusu', () {
      final message = deleteGoalDialogMessage(
        l10n,
        buildGoal(
          title: 'Meditasyon',
          templateId: 'growth_free',
          type: MetricType.freeText,
          totalXpEarned: 200,
        ),
      );
      expect(
        message,
        "'Meditasyon' hedefinde şimdiye kadar 200 XP kazandın. "
        'Bu hedefi silersen bu ilerleme geçmişi de silinir.',
      );
    });

    test('numeric ama değerler eksikse XP mesajına düşer', () {
      final message = deleteGoalDialogMessage(
        l10n,
        buildGoal(totalXpEarned: 50),
      );
      expect(message, contains('şimdiye kadar 50 XP kazandın'));
    });
  });
}
