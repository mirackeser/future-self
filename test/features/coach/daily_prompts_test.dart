import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/features/coach/domain/daily_prompts.dart';
import 'package:future_self/l10n/app_localizations.dart';

final _l10n = lookupAppLocalizations(const Locale('tr'));

void main() {
  group('todayPromptType', () {
    test('aynı gün içinde deterministik', () {
      expect(
        todayPromptType(now: DateTime(2026, 7, 8, 6)),
        todayPromptType(now: DateTime(2026, 7, 8, 23)),
      );
    });

    test('ardışık üç gün üç farklı tipi dolaşır', () {
      final types = [
        for (var i = 0; i < 3; i++)
          todayPromptType(now: DateTime(2026, 7, 8 + i)),
      ];
      expect(types.toSet(), DailyPromptType.values.toSet());
    });

    test('rotasyon dayOfYear % 3 sözleşmesine uyar', () {
      final date = DateTime(2026, 7, 8);
      final dayOfYear = date.difference(DateTime(2026)).inDays;
      expect(
        todayPromptType(now: date),
        DailyPromptType.values[dayOfYear % 3],
      );
      // 3 gün sonra aynı tip geri gelir.
      expect(
        todayPromptType(now: date.add(const Duration(days: 3))),
        todayPromptType(now: date),
      );
    });
  });

  test('söz ve ipucu günlük rotasyonda deterministik', () {
    final date = DateTime(2026, 7, 8);
    expect(quoteForToday(_l10n, now: date), quoteForToday(_l10n, now: date));
    expect(actionTipForToday(_l10n, now: date), actionTipForToday(_l10n, now: date));
    expect(
      quoteForToday(_l10n, now: date),
      isNot(quoteForToday(_l10n, now: date.add(const Duration(days: 1)))),
    );
  });

  test('listeler yeterince dolu', () {
    expect(motivationalQuotes(_l10n).length, greaterThanOrEqualTo(15));
    expect(actionTips(_l10n).length, greaterThanOrEqualTo(15));
  });
}
