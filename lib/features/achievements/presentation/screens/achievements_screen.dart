import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/personal_records.dart';
import '../achievements_providers.dart';

/// Başarılar: kişisel rekor panosu + rozet koleksiyonu.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievementsTitle)),
      body: SafeArea(
        child: dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.achievementsLoadError('$e')),
            ),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              Text(
                l10n.personalRecords,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _RecordsGrid(records: data.records),
              const SizedBox(height: 24),
              Text(
                l10n.badgesCount(
                  data.unlockedBadgeIds.length,
                  BadgeCatalog.all.length,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
                children: [
                  for (final badge in BadgeCatalog.all)
                    _BadgeTile(
                      badge: badge,
                      unlocked: data.unlockedBadgeIds.contains(badge.id),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordsGrid extends StatelessWidget {
  const _RecordsGrid({required this.records});

  final PersonalRecords records;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RecordCard(
                icon: Icons.local_fire_department,
                value: l10n.daysCount(records.longestStreakEver),
                label: l10n.recordLongestStreak,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RecordCard(
                icon: Icons.star_outline,
                value: l10n.xpValue(records.totalXp),
                label: l10n.recordTotalXp,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RecordCard(
                icon: Icons.emoji_events_outlined,
                value: '${records.completedGoalsCount}',
                label: l10n.recordCompletedGoals,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RecordCard(
                icon: Icons.checklist,
                value: '${records.completedMissionsCount}',
                label: l10n.recordCompletedMissions,
              ),
            ),
          ],
        ),
        if (records.fastestProgressingGoal != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.speed, size: 20, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.recordFastestGoal(
                        records.fastestProgressingGoal!.displayTitle(context),
                      ),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(height: 8),
            Text(value, style: textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.unlocked});

  final BadgeDefinition badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: Icon(
              unlocked ? badge.icon : Icons.lock_outline,
              size: 24,
              color: unlocked ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.localizedTitle(context),
            style: textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
