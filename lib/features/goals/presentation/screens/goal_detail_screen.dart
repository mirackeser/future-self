import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/goals_repository.dart';
import '../goals_providers.dart';
import '../widgets/quick_update_sheet.dart';

/// Silme dialog'u başlığı — streak varsa onu vurgular.
///
/// Motive edici ama suçlamayan bir dil; karar kullanıcının. Pure
/// kalması için context yerine [l10n] alır.
String deleteGoalDialogTitle(AppLocalizations l10n, Goal goal) {
  if (goal.streakCount > 0) {
    return l10n.deleteDialogStreakTitle(goal.streakCount);
  }
  return l10n.deleteDialogGenericTitle;
}

/// Silme dialog'u mesajı — değerler varsa yolculuğu, yoksa XP'yi vurgular.
String deleteGoalDialogMessage(AppLocalizations l10n, Goal goal) {
  final initial = goal.initialValue;
  final current = goal.currentValue;

  if (goal.type != MetricType.freeText && initial != null && current != null) {
    return l10n.deleteDialogMessageWithValues(
      goal.displayTitleWith(l10n),
      _formatGoalValue(goal, initial),
      _formatGoalValue(goal, current),
      goal.totalXpEarned,
    );
  }
  return l10n.deleteDialogMessageXpOnly(
      goal.displayTitleWith(l10n), goal.totalXpEarned);
}

/// Sayısal değeri (varsa birimiyle), level indeksini seviye adıyla yazar.
String _formatGoalValue(Goal goal, double value) {
  final template = MetricTemplates.byId(goal.metricTemplateId);
  if (goal.type == MetricType.level) {
    final index = value.round();
    if (index >= 0 && index < template.levelOptions.length) {
      return template.levelOptions[index];
    }
    return value.toString();
  }
  final number = value == value.roundToDouble()
      ? value.round().toString()
      : value.toString();
  return template.unit == null ? number : '$number ${template.unit}';
}

/// Hedef detayı: büyük ilerleme kartı, istatistikler, geçmiş ve silme.
class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return goalsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(AppLocalizations.of(context)!.goalLoadError('$e')),
        ),
      ),
      data: (goals) {
        Goal? goal;
        for (final g in goals) {
          if (g.id == goalId) {
            goal = g;
            break;
          }
        }
        if (goal == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(AppLocalizations.of(context)!.goalNotFound),
            ),
          );
        }
        return _GoalDetailBody(goal: goal);
      },
    );
  }
}

class _GoalDetailBody extends ConsumerWidget {
  const _GoalDetailBody({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteGoalTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(goal.icon, size: 32, color: scheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              goal.displayTitle(context),
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              goal.category.localizedLabel(context),
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _ProgressCard(goal: goal),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    value: l10n.daysCount(goal.streakCount),
                    label: l10n.streakLabel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_outline,
                    value: l10n.xpValue(goal.totalXpEarned),
                    label: l10n.earnedLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => showQuickUpdateSheet(context, goal),
                icon: const Icon(Icons.bolt),
                label: Text(l10n.recordProgress),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.historyLabel, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _HistoryList(goalId: goal.id),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(deleteGoalDialogTitle(l10n, goal)),
        content: Text(deleteGoalDialogMessage(l10n, goal)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.keepGoing),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => _delete(context, dialogContext, ref),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                child: Text(l10n.deleteAnyway),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    BuildContext dialogContext,
    WidgetRef ref,
  ) async {
    Navigator.of(dialogContext).pop();
    try {
      await ref.read(goalsRepositoryProvider).deleteGoal(goal.id);
      if (context.mounted) context.go(AppRoutes.dashboard);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.deleteFailed),
          ),
        );
      }
    }
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final percent = goal.progressPercent;
    final estimated = goal.estimatedCompletion();

    final String currentText;
    final String targetText;
    switch (goal.type) {
      case MetricType.numeric:
        currentText = goal.currentValue == null
            ? '—'
            : _formatGoalValue(goal, goal.currentValue!);
        targetText = goal.targetValue == null
            ? '—'
            : _formatGoalValue(goal, goal.targetValue!);
      case MetricType.level:
        currentText = goal.currentLevel ?? '—';
        targetText = goal.targetLevel ?? '—';
      case MetricType.freeText:
        currentText = l10n.inProgress;
        targetText = goal.targetText ?? '—';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  percent == null
                      ? l10n.inProgress
                      : l10n.percentOnly((percent * 100).round()),
                  style: textTheme.headlineMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                const Spacer(),
                // %100'de tahmini tarih anlamsız; tamamlandı yazılır.
                if (percent != null && percent >= 1.0)
                  Text(
                    l10n.goalCompleted,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else if (estimated != null)
                  Text(
                    l10n.estimatedDate(DateFormat('d.M.y').format(estimated)),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (percent != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: percent, minHeight: 8),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.nowValue(currentText),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.targetValueText(targetText),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final historyAsync = ref.watch(goalHistoryProvider(goalId));

    return historyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(
        AppLocalizations.of(context)!.historyLoadError,
        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Text(
            AppLocalizations.of(context)!.noHistoryYet,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          );
        }
        return Column(
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(
                      DateFormat('d.M.y HH:mm').format(entry.timestamp),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _historyLabel(AppLocalizations.of(context)!, entry),
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  static String _historyLabel(AppLocalizations l10n, GoalHistoryEntry entry) {
    String formatNumber(double v) =>
        v == v.roundToDouble() ? v.round().toString() : v.toString();

    if (entry.newValue != null) {
      final previous = entry.previousValue;
      return previous == null
          ? formatNumber(entry.newValue!)
          : '${formatNumber(previous)} → ${formatNumber(entry.newValue!)}';
    }
    if (entry.newLevel != null) {
      final previous = entry.previousLevel;
      return previous == null
          ? entry.newLevel!
          : '$previous → ${entry.newLevel!}';
    }
    // Not: Firestore'daki kayıtlı not (Türkçe) olduğu gibi gösterilir;
    // sadece boş fallback yerelleştirilir.
    return entry.note ?? l10n.progressRecorded;
  }
}
