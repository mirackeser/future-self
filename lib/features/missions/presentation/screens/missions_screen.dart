import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../missions_providers.dart';
import '../widgets/add_mission_sheet.dart';

/// Life Missions listesi: bucket list, nazik hatırlatmalarla.
class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(missionsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lifeMissions)),
      floatingActionButton: FloatingActionButton(
        // IndexedStack'te tüm sekmeler bellekte; varsayılan hero tag
        // çakışmasın diye benzersiz tag şart.
        heroTag: 'missions_fab',
        onPressed: () => showAddMissionSheet(context),
        tooltip: l10n.addMission,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: missionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.missionsLoadError('$e')),
            ),
          ),
          data: (missions) => missions.isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 88),
                  children: [
                    Text(
                      l10n.missionsSummary(
                        missions.length,
                        missions.where((m) => m.isCompleted).length,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    for (final mission in missions) ...[
                      _MissionCard(mission: mission),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return Opacity(
      opacity: mission.isCompleted ? 0.55 : 1,
      child: Card(
        child: InkWell(
          onTap: () => context.push(AppRoutes.missionDetailPath(mission.id)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(mission.icon, size: 24, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: textTheme.titleSmall?.copyWith(
                          decoration: mission.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!
                            .addedDaysAgo(mission.daysSinceCreation),
                        style: muted,
                      ),
                      const SizedBox(height: 8),
                      _statusLine(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusLine(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    if (mission.isCompleted) {
      final daysAgo = mission.completedAt == null
          ? null
          : DateTime.now().difference(mission.completedAt!).inDays;
      return Text(
        daysAgo == null
            ? l10n.completedLabel
            : l10n.completedDaysAgo(daysAgo),
        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    if (mission.needsGentleReminder) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.gentleReminder(mission.daysSinceLastActivity),
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
      );
    }

    final lastNote = mission.notes.isEmpty ? null : mission.notes.last;
    return Text(
      lastNote?.text ?? l10n.noNotesYet,
      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined,
                size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noMissionsYet,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noMissionsYetSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
