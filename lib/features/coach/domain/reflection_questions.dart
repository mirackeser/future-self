/// Günlük yansıma soruları — deterministik günlük rotasyon.
///
/// Sorular ARB'de (reflectionQuestion1..22); locale bilgisi [l10n]
/// parametresiyle gelir, yanıtlar Firestore'a soru metniyle birlikte
/// yazıldığı için o günkü dil kayıtta korunur.
library;

import '../../../l10n/app_localizations.dart';

/// Sabit soru havuzu; sıra değiştirilirse günün sorusu da kayar.
List<String> reflectionQuestions(AppLocalizations l10n) => [
      l10n.reflectionQuestion1,
      l10n.reflectionQuestion2,
      l10n.reflectionQuestion3,
      l10n.reflectionQuestion4,
      l10n.reflectionQuestion5,
      l10n.reflectionQuestion6,
      l10n.reflectionQuestion7,
      l10n.reflectionQuestion8,
      l10n.reflectionQuestion9,
      l10n.reflectionQuestion10,
      l10n.reflectionQuestion11,
      l10n.reflectionQuestion12,
      l10n.reflectionQuestion13,
      l10n.reflectionQuestion14,
      l10n.reflectionQuestion15,
      l10n.reflectionQuestion16,
      l10n.reflectionQuestion17,
      l10n.reflectionQuestion18,
      l10n.reflectionQuestion19,
      l10n.reflectionQuestion20,
      l10n.reflectionQuestion21,
      l10n.reflectionQuestion22,
    ];

/// Bugünün sorusu: aynı gün içinde hep aynı, ertesi gün değişir.
///
/// [now] testlerde sabitlemek için enjekte edilebilir.
String questionForToday(AppLocalizations l10n, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final dayOfYear = clock.difference(DateTime(clock.year)).inDays;
  final questions = reflectionQuestions(l10n);
  return questions[dayOfYear % questions.length];
}
