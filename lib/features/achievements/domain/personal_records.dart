/// Kişisel rekor panosu hesapları — pure fonksiyonlar.
///
/// Not: "en yüksek haftalık XP" bilinçli olarak yok — haftalık XP
/// geçmişi ancak chapters verisinden toplanabilir; istenirse ileride
/// oradan eklenebilir.
library;

import '../../../core/models/models.dart';

class PersonalRecords {
  const PersonalRecords({
    required this.longestStreakEver,
    required this.totalXp,
    required this.completedGoalsCount,
    required this.completedMissionsCount,
    this.fastestProgressingGoal,
  });

  final int longestStreakEver;
  final int totalXp;
  final int completedGoalsCount;
  final int completedMissionsCount;

  /// Günlük ilerleme hızı (yüzde / geçen gün) en yüksek olan hedef.
  /// Başlık değil Goal döner: UI, displayTitle ile o anki dilde gösterir.
  final Goal? fastestProgressingGoal;
}

PersonalRecords computeRecords(
  List<Goal> goals,
  UserProgress progress,
  List<Mission> missions, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();

  Goal? fastest;
  double bestRate = 0;
  for (final goal in goals) {
    final percent = goal.progressPercent;
    if (percent == null || percent <= 0) continue;
    final elapsedDays = clock.difference(goal.createdAt).inDays.clamp(1, 36500);
    final rate = percent / elapsedDays;
    if (rate > bestRate) {
      bestRate = rate;
      fastest = goal;
    }
  }

  return PersonalRecords(
    longestStreakEver: progress.longestStreakEver > progress.currentStreak
        ? progress.longestStreakEver
        : progress.currentStreak,
    totalXp: progress.totalXp,
    completedGoalsCount:
        goals.where((g) => g.progressPercent == 1.0).length,
    completedMissionsCount: missions.where((m) => m.isCompleted).length,
    fastestProgressingGoal: fastest,
  );
}
