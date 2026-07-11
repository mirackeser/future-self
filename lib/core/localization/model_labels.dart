/// Enum/model etiketlerinin yerelleştirilmesi.
///
/// Category ve MetricTemplate saf model olduğundan ARB'yi doğrudan
/// kullanamaz; buradaki extension'lar AppLocalizations üzerinden
/// eşleme yapar. Modellerdeki `label` alanları veri katmanı için
/// (örn. Goal.title'a yazım) korunur; UI bu extension'ları kullanır.
library;

import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../models/models.dart';

extension CategoryL10n on Category {
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      Category.health => l10n.categoryHealth,
      Category.career => l10n.categoryCareer,
      Category.finance => l10n.categoryFinance,
      Category.learning => l10n.categoryLearning,
      Category.relationships => l10n.categoryRelationships,
      Category.spirituality => l10n.categorySpirituality,
      Category.personalGrowth => l10n.categoryPersonalGrowth,
    };
  }
}

extension ChallengeL10n on WeeklyChallenge {
  /// Haftalık meydan okuma başlığı, o anki dile göre canlı üretilir.
  String displayTitle(BuildContext context) =>
      displayTitleWith(AppLocalizations.of(context)!);

  String displayTitleWith(AppLocalizations l10n) {
    return switch (type) {
      ChallengeType.threeDayUpdateStreak => l10n.challengeThreeDayStreak,
      ChallengeType.twoGoalsProgress => l10n.challengeTwoGoals,
      ChallengeType.addMissionNote => l10n.challengeMissionNote,
      ChallengeType.answerReflection => l10n.challengeReflection,
      ChallengeType.commentOnLesson => l10n.challengeComment,
      ChallengeType.tenPercentOnAnyGoal => l10n.challengeTenPercent,
    };
  }
}

extension BadgeL10n on BadgeDefinition {
  String localizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (id) {
      'streak_7' => l10n.badgeStreak7,
      'streak_30' => l10n.badgeStreak30,
      'streak_100' => l10n.badgeStreak100,
      'goal_first_added' => l10n.badgeFirstGoal,
      'goal_first_completed' => l10n.badgeFirstGoalCompleted,
      'goals_5_completed' => l10n.badgeGoals5,
      'goals_10_completed' => l10n.badgeGoals10,
      'mission_first_added' => l10n.badgeFirstMission,
      'mission_first_completed' => l10n.badgeFirstMissionCompleted,
      'missions_5_completed' => l10n.badgeMissions5,
      'lesson_first_shared' => l10n.badgeFirstLesson,
      'comment_first' => l10n.badgeFirstComment,
      'lesson_50_likes' => l10n.badgeLesson50Likes,
      'comeback' => l10n.badgeComeback,
      'early_bird' => l10n.badgeEarlyBird,
      'level_10' => l10n.badgeLevel10,
      'level_25' => l10n.badgeLevel25,
      _ => id,
    };
  }
}

extension GoalL10n on Goal {
  /// Ekranda gösterilecek hedef başlığı, o anki dile göre.
  ///
  /// Şablondan üretilmiş hedeflerde başlık şablonun yerelleştirilmiş
  /// etiketidir (dil değişince güncellenir); freeText hedeflerde ve
  /// katalogda karşılığı olmayan id'lerde kullanıcının kendi yazdığı
  /// [title] olduğu gibi gösterilir (çevrilmez). Firestore'daki title
  /// alanı geriye dönük uyumluluk için aynen durur.
  String displayTitle(BuildContext context) =>
      displayTitleWith(AppLocalizations.of(context)!);

  /// Context'siz pure fonksiyonlar (dialog metinleri, coach motoru) için.
  String displayTitleWith(AppLocalizations l10n) {
    if (type == MetricType.freeText) return title;
    return MetricTemplates.byIdOrNull(metricTemplateId)
            ?.localizedLabelWith(l10n) ??
        title;
  }
}

extension MetricTemplateL10n on MetricTemplate {
  String localizedLabel(BuildContext context) =>
      localizedLabelWith(AppLocalizations.of(context)!);

  String localizedLabelWith(AppLocalizations l10n) {
    return switch (id) {
      'health_weight' => l10n.templateWeight,
      'health_exercise' => l10n.templateExerciseFrequency,
      'health_free' ||
      'relationships_free' ||
      'spirituality_free' ||
      'growth_free' =>
        l10n.templateFreeGoal,
      'career_level' => l10n.templateCareerLevel,
      'career_position' => l10n.templateTargetPosition,
      'career_salary' => l10n.templateSalary,
      'finance_savings' => l10n.templateSavings,
      'finance_gold' => l10n.templateGold,
      'finance_crypto' => l10n.templateCrypto,
      'finance_debt' => l10n.templateCardDebt,
      'learning_language' => l10n.templateLanguageLevel,
      'learning_topic' => l10n.templateTopicCourse,
      // Katalogda karşılığı olmayan id: Türkçe varsayılan etiket.
      _ => label,
    };
  }
}
