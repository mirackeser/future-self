/// Günlük içerik rotasyonu: yansıma sorusu / motive edici söz /
/// eylem ipucu arasında deterministik dönüşüm.
///
/// Metinler ARB'de (motivationalQuote1..16, actionTip1..16); locale
/// bilgisi [l10n] parametresiyle gelir.
library;

import '../../../l10n/app_localizations.dart';

/// Coach'taki günlük kartın tipi.
enum DailyPromptType { reflectionQuestion, motivationalQuote, actionTip }

/// Kısa, sakin, Future Self temalı motive edici sözler.
List<String> motivationalQuotes(AppLocalizations l10n) => [
      l10n.motivationalQuote1,
      l10n.motivationalQuote2,
      l10n.motivationalQuote3,
      l10n.motivationalQuote4,
      l10n.motivationalQuote5,
      l10n.motivationalQuote6,
      l10n.motivationalQuote7,
      l10n.motivationalQuote8,
      l10n.motivationalQuote9,
      l10n.motivationalQuote10,
      l10n.motivationalQuote11,
      l10n.motivationalQuote12,
      l10n.motivationalQuote13,
      l10n.motivationalQuote14,
      l10n.motivationalQuote15,
      l10n.motivationalQuote16,
    ];

/// Genel, uygulanabilir eylem ipuçları.
List<String> actionTips(AppLocalizations l10n) => [
      l10n.actionTip1,
      l10n.actionTip2,
      l10n.actionTip3,
      l10n.actionTip4,
      l10n.actionTip5,
      l10n.actionTip6,
      l10n.actionTip7,
      l10n.actionTip8,
      l10n.actionTip9,
      l10n.actionTip10,
      l10n.actionTip11,
      l10n.actionTip12,
      l10n.actionTip13,
      l10n.actionTip14,
      l10n.actionTip15,
      l10n.actionTip16,
    ];

int _dayOfYear(DateTime date) => date.difference(DateTime(date.year)).inDays;

/// Bugünün kart tipi: üç tip arasında günlük deterministik rotasyon.
DailyPromptType todayPromptType({DateTime? now}) {
  final clock = now ?? DateTime.now();
  return DailyPromptType
      .values[_dayOfYear(clock) % DailyPromptType.values.length];
}

/// Günün sözü (motivationalQuote günlerinde gösterilir).
String quoteForToday(AppLocalizations l10n, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final quotes = motivationalQuotes(l10n);
  return quotes[_dayOfYear(clock) % quotes.length];
}

/// Günün eylem ipucu (actionTip günlerinde gösterilir).
String actionTipForToday(AppLocalizations l10n, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final tips = actionTips(l10n);
  return tips[_dayOfYear(clock) % tips.length];
}
