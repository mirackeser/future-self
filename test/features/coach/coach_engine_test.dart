import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/coach/domain/coach_engine.dart';
import 'package:future_self/features/coach/domain/reflection_questions.dart';
import 'package:future_self/l10n/app_localizations.dart';

final _now = DateTime(2026, 7, 7, 12);
final _l10n = lookupAppLocalizations(const Locale('tr'));

Goal buildGoal(
  String id, {
  String? title,
  String metricTemplateId = 'health_weight',
  MetricType type = MetricType.numeric,
  double? initialValue = 0,
  double? currentValue = 0,
  double? targetValue = 100,
  DateTime? lastProgressUpdateAt,
  DateTime? createdAt,
}) {
  return Goal(
    id: id,
    userId: 'u1',
    category: Category.health,
    title: title ?? id,
    metricTemplateId: metricTemplateId,
    type: type,
    initialValue: initialValue,
    currentValue: currentValue,
    targetValue: targetValue,
    createdAt: createdAt ?? _now.subtract(const Duration(days: 30)),
    lastProgressUpdateAt: lastProgressUpdateAt,
  );
}

void main() {
  group('buildInsights', () {
    test('hedefsiz kullanıcı: tek empty insight', () {
      final insights = buildInsights(
        _l10n,
        const [],
        const UserProgress(),
        now: _now,
      );

      expect(insights, hasLength(1));
      expect(insights.single.type, CoachInsightType.empty);
    });

    test('yüksek streak: en ilerlemiş hedefe referanslı vurgu', () {
      final goals = [
        buildGoal(
          'g1',
          title: 'Kilo',
          currentValue: 20,
          lastProgressUpdateAt: _now.subtract(const Duration(days: 1)),
        ),
        buildGoal(
          'g2',
          title: 'Birikim',
          metricTemplateId: 'finance_savings',
          currentValue: 80, // %80 — en yüksek ilerleme
          lastProgressUpdateAt: _now.subtract(const Duration(days: 1)),
        ),
      ];

      final insights = buildInsights(
        _l10n,
        goals,
        const UserProgress(currentStreak: 9),
        now: _now,
      );

      final streak = insights.singleWhere(
        (i) => i.type == CoachInsightType.streakHighlight,
      );
      expect(streak.message, contains('9 günlük'));
      expect(streak.message, contains('Birikim'));
      expect(streak.goalId, 'g2');
    });

    test('streak 7\'nin altındaysa vurgu yok', () {
      final goals = [
        buildGoal(
          'g1',
          lastProgressUpdateAt: _now.subtract(const Duration(days: 1)),
        ),
      ];
      final insights = buildInsights(
        _l10n,
        goals,
        const UserProgress(currentStreak: 6),
        now: _now,
      );

      expect(
        insights.where((i) => i.type == CoachInsightType.streakHighlight),
        isEmpty,
      );
    });

    test('7+ gündür dokunulmamış hedef ihmal uyarısı üretir, '
        'freeText hedef seçilmez', () {
      final goals = [
        buildGoal(
          'stale',
          title: 'Kilo',
          lastProgressUpdateAt: _now.subtract(const Duration(days: 10)),
        ),
        buildGoal(
          'freetext',
          title: 'Meditasyon',
          type: MetricType.freeText,
          createdAt: _now.subtract(const Duration(days: 60)),
        ),
        buildGoal(
          'fresh',
          lastProgressUpdateAt: _now.subtract(const Duration(days: 1)),
        ),
      ];

      final insights = buildInsights(
        _l10n,
        goals,
        const UserProgress(),
        now: _now,
      );

      final neglected = insights.singleWhere(
        (i) => i.type == CoachInsightType.neglectedGoal,
      );
      expect(neglected.goalId, 'stale');
      expect(neglected.message, contains('10 gündür'));
      expect(neglected.message, contains('Kilo'));
    });

    test('taze hedeflerde ihmal uyarısı çıkmaz', () {
      final goals = [
        buildGoal(
          'g1',
          lastProgressUpdateAt: _now.subtract(const Duration(days: 2)),
        ),
      ];
      final insights = buildInsights(
        _l10n,
        goals,
        const UserProgress(),
        now: _now,
      );

      expect(
        insights.where((i) => i.type == CoachInsightType.neglectedGoal),
        isEmpty,
      );
    });

    test('hedef önerileri: düzenliye olumlu, kayıtsıza dürtükleme, '
        'en fazla 3', () {
      final goals = [
        buildGoal(
          'regular',
          title: 'Kilo',
          lastProgressUpdateAt: _now.subtract(const Duration(days: 3)),
        ),
        buildGoal('untouched1',
            title: 'Birikim', metricTemplateId: 'finance_savings'),
        buildGoal('untouched2', title: 'Egzersiz'),
        buildGoal('untouched3', title: 'Dil'),
        buildGoal('untouched4', title: 'Maaş'),
      ];

      final insights = buildInsights(
        _l10n,
        goals,
        const UserProgress(),
        now: _now,
      );

      final tips = insights
          .where((i) => i.type == CoachInsightType.goalTip)
          .toList();
      expect(tips, hasLength(3));
      expect(tips.first.goalId, 'regular');
      // Düzenli hedefe olumlu şablonlardan biri, kayıtsıza dürtükleme
      // şablonlarından biri düşer.
      expect(
        regularGoalTipVariants(_l10n, 'Kilo'),
        contains(tips.first.message),
      );
      expect(
        untouchedGoalTipVariants(_l10n, 'Birikim'),
        contains(tips[1].message),
      );
    });

    test('cümle seçimi: aynı gün farklı hedefler farklı cümle alabilir, '
        'aynı hedef tutarlı kalır', () {
      // Hash tabanlı seçimde belirli iki id çakışabilir; test, farklı
      // indeks veren iki id'yi kendisi bulur (garanti var: hashCode'lar
      // sonsuz sayıda id üzerinde aynı kalamaz).
      final variantCount = untouchedGoalTipVariants(_l10n, 'x').length;
      final baseIndex = tipVariantIndex('goal-0', _now, variantCount);
      String? differingId;
      for (var i = 1; i < 100; i++) {
        if (tipVariantIndex('goal-$i', _now, variantCount) != baseIndex) {
          differingId = 'goal-$i';
          break;
        }
      }
      expect(
        differingId,
        isNotNull,
        reason: '100 id içinde farklı varyant çıkmalıydı',
      );

      final goals = [
        buildGoal('goal-0', title: 'Hedef A'),
        buildGoal(differingId!, title: 'Hedef A'),
      ];
      final insights = buildInsights(
        _l10n,
        goals,
        const UserProgress(),
        now: _now,
      );
      final tips = insights
          .where((i) => i.type == CoachInsightType.goalTip)
          .toList();

      // Aynı başlık, farklı id → farklı şablon seçildi.
      expect(tips[0].message, isNot(tips[1].message));

      // Aynı gün içinde ikinci çağrı birebir aynı sonucu verir.
      final again = buildInsights(
        _l10n,
        goals,
        const UserProgress(),
        now: _now,
      ).where((i) => i.type == CoachInsightType.goalTip).toList();
      expect(again[0].message, tips[0].message);
      expect(again[1].message, tips[1].message);
    });

    test('karışık durum: sıra streak → ihmal → öneriler', () {
      final goals = [
        buildGoal(
          'stale',
          lastProgressUpdateAt: _now.subtract(const Duration(days: 20)),
        ),
        buildGoal(
          'fresh',
          currentValue: 50,
          lastProgressUpdateAt: _now.subtract(const Duration(days: 1)),
        ),
      ];

      final insights = buildInsights(
        _l10n,
        goals,
        const UserProgress(currentStreak: 12),
        now: _now,
      );

      final types = insights.map((i) => i.type).toList();
      expect(types.first, CoachInsightType.streakHighlight);
      expect(types[1], CoachInsightType.neglectedGoal);
      expect(types.sublist(2), everyElement(CoachInsightType.goalTip));
      expect(insights.where((i) => i.type == CoachInsightType.empty), isEmpty);
    });
  });

  group('questionForToday', () {
    test('aynı gün içinde deterministik', () {
      final morning = DateTime(2026, 7, 7, 6);
      final evening = DateTime(2026, 7, 7, 23, 59);

      expect(
        questionForToday(_l10n, now: morning),
        questionForToday(_l10n, now: evening),
      );
    });

    test('beklenen indeksteki soruyu döner', () {
      final date = DateTime(2026, 7, 7);
      final dayOfYear = date.difference(DateTime(2026)).inDays;
      final questions = reflectionQuestions(_l10n);
      expect(
        questionForToday(_l10n, now: date),
        questions[dayOfYear % questions.length],
      );
    });

    test('ertesi gün soru değişir', () {
      expect(
        questionForToday(_l10n, now: DateTime(2026, 7, 7)),
        isNot(questionForToday(_l10n, now: DateTime(2026, 7, 8))),
      );
    });
  });
}
