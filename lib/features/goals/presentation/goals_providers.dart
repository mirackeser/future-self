/// goals özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../data/goals_repository.dart';

/// Kullanıcının hedefleri, gerçek zamanlı.
final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(goalsRepositoryProvider).watchGoals();
});

/// Kullanıcının XP/level/streak durumu, gerçek zamanlı.
final userProgressStreamProvider = StreamProvider<UserProgress>((ref) {
  return ref.watch(goalsRepositoryProvider).watchUserProgress();
});

/// Bir hedefin ilerleme geçmişi (en yeni önce, son 20 kayıt).
final goalHistoryProvider =
    StreamProvider.family<List<GoalHistoryEntry>, String>((ref, goalId) {
  return ref.watch(goalsRepositoryProvider).watchGoalHistory(goalId);
});
