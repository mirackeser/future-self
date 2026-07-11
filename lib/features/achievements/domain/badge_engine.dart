/// Rozet kilit açma kuralları — pure fonksiyonlar.
library;

import '../../../core/models/models.dart';

/// Açık rozetlerin id kümesini hesaplar; hiçbir yere kaydedilmez,
/// her seferinde canlı veriden değerlendirilir.
Set<String> evaluateUnlockedBadges(
  List<Goal> goals,
  UserProgress progress,
  List<Mission> missions,
  List<Lesson> myLessons,
  int totalComments,
) {
  final unlocked = <String>{};

  final maxStreak = progress.longestStreakEver > progress.currentStreak
      ? progress.longestStreakEver
      : progress.currentStreak;
  if (maxStreak >= 7) unlocked.add('streak_7');
  if (maxStreak >= 30) unlocked.add('streak_30');
  if (maxStreak >= 100) unlocked.add('streak_100');

  final completedGoals =
      goals.where((g) => g.progressPercent == 1.0).length;
  if (goals.isNotEmpty) unlocked.add('goal_first_added');
  if (completedGoals >= 1) unlocked.add('goal_first_completed');
  if (completedGoals >= 5) unlocked.add('goals_5_completed');
  if (completedGoals >= 10) unlocked.add('goals_10_completed');

  final completedMissions = missions.where((m) => m.isCompleted).length;
  if (missions.isNotEmpty) unlocked.add('mission_first_added');
  if (completedMissions >= 1) unlocked.add('mission_first_completed');
  if (completedMissions >= 5) unlocked.add('missions_5_completed');

  if (myLessons.isNotEmpty) unlocked.add('lesson_first_shared');
  if (totalComments >= 1) unlocked.add('comment_first');
  if (myLessons.any((l) => l.likeCount >= 50)) {
    unlocked.add('lesson_50_likes');
  }

  // Geri Dönüş: geçmişte daha uzun bir seri vardı (yani seri kırılmış)
  // ve yeniden 7+ güne çıkılmış.
  if (progress.currentStreak >= 7 &&
      progress.longestStreakEver > progress.currentStreak) {
    unlocked.add('comeback');
  }

  // Erken Kalkan: herhangi bir hedefe sabah 05:00-08:00 arasında
  // ilerleme kaydedilmiş (eldeki son güncelleme zamanından).
  if (goals.any((g) {
    final at = g.lastProgressUpdateAt;
    return at != null && at.hour >= 5 && at.hour < 8;
  })) {
    unlocked.add('early_bird');
  }

  if (progress.level >= 10) unlocked.add('level_10');
  if (progress.level >= 25) unlocked.add('level_25');

  return unlocked;
}
