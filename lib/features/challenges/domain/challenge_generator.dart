/// Haftalık meydan okuma üretici — pure fonksiyonlar.
library;

import '../../../core/models/models.dart';

/// Tip başına sabit sayısal tanımlar.
///
/// Başlıklar burada DEĞİL, ARB'dedir; görüntülemede type'tan üretilir
/// (bkz. ChallengeL10n.displayTitle).
class ChallengeSpec {
  const ChallengeSpec({required this.targetValue, required this.xpReward});

  final int targetValue;
  final int xpReward;
}

const Map<ChallengeType, ChallengeSpec> challengeSpecs = {
  ChallengeType.threeDayUpdateStreak:
      ChallengeSpec(targetValue: 3, xpReward: 75),
  ChallengeType.twoGoalsProgress: ChallengeSpec(targetValue: 2, xpReward: 60),
  ChallengeType.addMissionNote: ChallengeSpec(targetValue: 1, xpReward: 40),
  ChallengeType.answerReflection: ChallengeSpec(targetValue: 1, xpReward: 40),
  ChallengeType.commentOnLesson: ChallengeSpec(targetValue: 1, xpReward: 40),
  ChallengeType.tenPercentOnAnyGoal:
      ChallengeSpec(targetValue: 1, xpReward: 80),
};

/// Haftanın meydan okuması: weekId + uid hash'iyle deterministik seçim.
/// Aynı kullanıcı aynı hafta hep aynı challenge'ı görür; farklı
/// haftalar/kullanıcılar dağılır.
WeeklyChallenge pickChallengeForWeek(String weekId, String uid) {
  final index =
      ('$weekId$uid').hashCode.abs() % ChallengeType.values.length;
  final type = ChallengeType.values[index];
  final spec = challengeSpecs[type]!;
  return WeeklyChallenge(
    id: weekId,
    type: type,
    targetValue: spec.targetValue,
    xpReward: spec.xpReward,
  );
}

/// Tek bir history kaydının hedef aralığına oranla ilerleme farkı
/// (0.10 = %10). Level kayıtlarında seviye indeksleri kullanılır;
/// hesaplanamıyorsa null.
double? entryProgressDelta(Goal goal, GoalHistoryEntry entry) {
  final initial = goal.initialValue;
  final target = goal.targetValue;
  if (initial == null || target == null || target == initial) return null;

  double? toValue(double? numeric, String? level) {
    if (goal.type == MetricType.numeric) return numeric;
    if (level == null) return null;
    final index = MetricTemplates.byId(goal.metricTemplateId)
        .levelOptions
        .indexOf(level);
    return index < 0 ? null : index.toDouble();
  }

  final previous = toValue(entry.previousValue, entry.previousLevel);
  final next = toValue(entry.newValue, entry.newLevel);
  if (previous == null || next == null) return null;
  return (next - previous) / (target - initial);
}
