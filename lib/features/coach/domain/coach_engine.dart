/// Kural tabanlı coach motoru — pure fonksiyonlar.
///
/// Gerçek AI entegrasyonu geldiğinde bu motor onun fallback'i /
/// başlangıç noktası olarak kalacak. Asla terapist/tıbbi uzman diliyle
/// konuşmaz, suçlayıcı ton kullanmaz. Sonuç hiçbir yere kaydedilmez;
/// ekran her build olduğunda o anki dille yeniden üretilir (bu yüzden
/// context yerine [AppLocalizations] alır).
library;

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../../core/localization/model_labels.dart';
import '../../../core/models/models.dart';
import '../../../l10n/app_localizations.dart';

/// En fazla bu kadar hedef bazlı öneri üretilir.
const int _maxGoalTips = 3;

/// Son 14 günde ilerleme kaydetmiş hedefler için cümle varyasyonları.
List<String> regularGoalTipVariants(AppLocalizations l10n, String title) => [
      l10n.coachTipRegular1(title),
      l10n.coachTipRegular2(title),
      l10n.coachTipRegular3(title),
      l10n.coachTipRegular4(title),
      l10n.coachTipRegular5(title),
      l10n.coachTipRegular6(title),
    ];

/// Henüz hiç ilerleme kaydı olmayan hedefler için cümle varyasyonları.
List<String> untouchedGoalTipVariants(AppLocalizations l10n, String title) => [
      l10n.coachTipUntouched1(title),
      l10n.coachTipUntouched2(title),
      l10n.coachTipUntouched3(title),
      l10n.coachTipUntouched4(title),
      l10n.coachTipUntouched5(title),
      l10n.coachTipUntouched6(title),
    ];

/// Hedefe ve güne göre deterministik varyant indeksi.
///
/// Aynı hedef aynı gün hep aynı cümleyi alır; farklı hedefler (hash
/// farkıyla) dağılır; gün değişince aynı hedefin cümlesi de kayabilir.
@visibleForTesting
int tipVariantIndex(String goalId, DateTime now, int optionCount) {
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  final seed = goalId.hashCode + dayOfYear + now.year * 373;
  return seed.abs() % optionCount;
}

/// Hedef ve ilerleme durumundan coach kartlarını üretir.
///
/// Sıra: streak vurgusu → ihmal uyarısı → hedef önerileri.
/// [now] testlerde sabitlemek için enjekte edilebilir.
List<CoachInsight> buildInsights(
  AppLocalizations l10n,
  List<Goal> goals,
  UserProgress progress, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();

  if (goals.isEmpty) {
    return [
      CoachInsight(
        type: CoachInsightType.empty,
        message: l10n.coachEmptyMessage,
      ),
    ];
  }

  final insights = <CoachInsight>[];

  // Streak vurgusu: 7+ günlük seride, en yüksek ilerlemeli hedefe
  // referans vererek kutla.
  if (progress.currentStreak >= 7) {
    Goal? topGoal;
    double topPercent = -1;
    for (final goal in goals) {
      final percent = goal.progressPercent;
      if (percent != null && percent > topPercent) {
        topPercent = percent;
        topGoal = goal;
      }
    }
    insights.add(
      CoachInsight(
        type: CoachInsightType.streakHighlight,
        goalId: topGoal?.id,
        message: topGoal == null
            ? l10n.coachStreakGeneric(progress.currentStreak)
            : l10n.coachStreakWithGoal(
                progress.currentStreak,
                topGoal.displayTitleWith(l10n),
              ),
      ),
    );
  }

  // İhmal uyarısı: freeText olmayan, en uzun süredir dokunulmamış hedef
  // 7+ gündür bekliyorsa nazikçe hatırlat.
  Goal? neglected;
  var neglectedDays = -1;
  for (final goal in goals) {
    if (goal.type == MetricType.freeText) continue;
    final lastTouch = goal.lastProgressUpdateAt ?? goal.createdAt;
    final days = clock.difference(lastTouch).inDays;
    if (days > neglectedDays) {
      neglectedDays = days;
      neglected = goal;
    }
  }
  if (neglected != null && neglectedDays >= 7) {
    insights.add(
      CoachInsight(
        type: CoachInsightType.neglectedGoal,
        goalId: neglected.id,
        message:
            l10n.coachNeglected(neglected.displayTitleWith(l10n), neglectedDays),
      ),
    );
  }

  // Hedef bazlı öneriler: son 14 günde kayıt varsa olumlu, hiç kayıt
  // yoksa nazik bir dürtükleme. En fazla üç öneri.
  for (final goal in goals) {
    if (insights.where((i) => i.type == CoachInsightType.goalTip).length >=
        _maxGoalTips) {
      break;
    }
    final lastTouch = goal.lastProgressUpdateAt;
    final List<String>? variants;
    if (lastTouch != null && clock.difference(lastTouch).inDays <= 14) {
      variants = regularGoalTipVariants(l10n, goal.displayTitleWith(l10n));
    } else if (lastTouch == null) {
      variants = untouchedGoalTipVariants(l10n, goal.displayTitleWith(l10n));
    } else {
      variants = null;
    }
    if (variants != null) {
      insights.add(
        CoachInsight(
          type: CoachInsightType.goalTip,
          goalId: goal.id,
          message:
              variants[tipVariantIndex(goal.id, clock, variants.length)],
        ),
      );
    }
  }

  return insights;
}
