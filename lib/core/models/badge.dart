import 'package:flutter/material.dart';

/// Rozet kategorileri.
enum BadgeCategory { streak, goals, missions, lessons, special }

/// Rozet tanımı (Flutter'ın Badge widget'ıyla çakışmasın diye AppBadge
/// ailesi). Başlık ARB'den gelir: model yalnızca [id] tutar, eşleme
/// model_labels.dart'taki BadgeL10n extension'ındadır.
class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.icon,
    required this.category,
  });

  final String id;
  final IconData icon;
  final BadgeCategory category;
}

/// Sabit rozet kataloğu.
abstract final class BadgeCatalog {
  static const List<BadgeDefinition> all = [
    // Streak
    BadgeDefinition(
      id: 'streak_7',
      icon: Icons.local_fire_department,
      category: BadgeCategory.streak,
    ),
    BadgeDefinition(
      id: 'streak_30',
      icon: Icons.whatshot,
      category: BadgeCategory.streak,
    ),
    BadgeDefinition(
      id: 'streak_100',
      icon: Icons.rocket_launch,
      category: BadgeCategory.streak,
    ),
    // Hedefler
    BadgeDefinition(
      id: 'goal_first_added',
      icon: Icons.flag,
      category: BadgeCategory.goals,
    ),
    BadgeDefinition(
      id: 'goal_first_completed',
      icon: Icons.emoji_events,
      category: BadgeCategory.goals,
    ),
    BadgeDefinition(
      id: 'goals_5_completed',
      icon: Icons.track_changes,
      category: BadgeCategory.goals,
    ),
    BadgeDefinition(
      id: 'goals_10_completed',
      icon: Icons.workspace_premium,
      category: BadgeCategory.goals,
    ),
    // Missions
    BadgeDefinition(
      id: 'mission_first_added',
      icon: Icons.explore,
      category: BadgeCategory.missions,
    ),
    BadgeDefinition(
      id: 'mission_first_completed',
      icon: Icons.star,
      category: BadgeCategory.missions,
    ),
    BadgeDefinition(
      id: 'missions_5_completed',
      icon: Icons.auto_awesome,
      category: BadgeCategory.missions,
    ),
    // Lessons
    BadgeDefinition(
      id: 'lesson_first_shared',
      icon: Icons.history_edu,
      category: BadgeCategory.lessons,
    ),
    BadgeDefinition(
      id: 'comment_first',
      icon: Icons.chat_bubble,
      category: BadgeCategory.lessons,
    ),
    BadgeDefinition(
      id: 'lesson_50_likes',
      icon: Icons.favorite,
      category: BadgeCategory.lessons,
    ),
    // Özel
    BadgeDefinition(
      id: 'comeback',
      icon: Icons.replay,
      category: BadgeCategory.special,
    ),
    BadgeDefinition(
      id: 'early_bird',
      icon: Icons.wb_twilight,
      category: BadgeCategory.special,
    ),
    BadgeDefinition(
      id: 'level_10',
      icon: Icons.trending_up,
      category: BadgeCategory.special,
    ),
    BadgeDefinition(
      id: 'level_25',
      icon: Icons.diamond,
      category: BadgeCategory.special,
    ),
  ];
}
