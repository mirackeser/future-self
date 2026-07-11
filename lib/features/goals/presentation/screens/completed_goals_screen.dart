import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../goals_providers.dart';

/// Tamamlanan (%100) hedeflerin listesi.
///
/// Tamamlanma anı olarak lastProgressUpdateAt kullanılır — %100'e
/// ulaştıran son güncellemenin zamanı. Karta dokununca hedef detayı.
class CompletedGoalsScreen extends ConsumerWidget {
  const CompletedGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.completedGoalsTitle)),
      body: SafeArea(
        child: goalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.goalsLoadError('$e')),
            ),
          ),
          data: (goals) {
            final epoch = DateTime.fromMillisecondsSinceEpoch(0);
            final completed = goals
                .where((g) => (g.progressPercent ?? 0) >= 1.0)
                .toList()
              // En son tamamlanan önce.
              ..sort(
                (a, b) => (b.lastProgressUpdateAt ?? epoch)
                    .compareTo(a.lastProgressUpdateAt ?? epoch),
              );
            if (completed.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.noCompletedGoalsYet,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              children: [
                for (final goal in completed) ...[
                  _CompletedGoalCard(goal: goal),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompletedGoalCard extends StatelessWidget {
  const _CompletedGoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final completedAt = goal.lastProgressUpdateAt;

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.goalDetailPath(goal.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(goal.icon, size: 24, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.displayTitle(context),
                      style: textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      completedAt == null
                          ? l10n.goalCompleted
                          : l10n.completedOnDate(
                              DateFormat('d.M.y').format(completedAt),
                            ),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.xpValue(goal.totalXpEarned),
                style: textTheme.labelLarge?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
