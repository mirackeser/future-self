/// achievements özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/presentation/goals_providers.dart';
import '../../lessons/data/lessons_repository.dart';
import '../../missions/presentation/missions_providers.dart';
import '../domain/badge_engine.dart';
import '../domain/personal_records.dart';

typedef AchievementsData = ({
  Set<String> unlockedBadgeIds,
  PersonalRecords records,
});

/// Rozetler + rekorlar; hedef/ilerleme/mission stream'leri her
/// güncellendiğinde yeniden hesaplanır (kaydedilmez).
final achievementsProvider = FutureProvider<AchievementsData>((ref) async {
  final goals = await ref.watch(goalsStreamProvider.future);
  final progress = await ref.watch(userProgressStreamProvider.future);
  final missions = await ref.watch(missionsStreamProvider.future);
  final lessonsRepository = ref.watch(lessonsRepositoryProvider);
  final myLessons = await lessonsRepository.fetchMyLessons();
  final totalComments = await lessonsRepository.countMyComments();

  return (
    unlockedBadgeIds:
        evaluateUnlockedBadges(goals, progress, missions, myLessons, totalComments),
    records: computeRecords(goals, progress, missions),
  );
});
