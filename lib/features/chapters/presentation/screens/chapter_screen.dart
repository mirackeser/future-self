import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/models.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../goals/presentation/goals_providers.dart';
import '../../domain/chapter_generator.dart';
import '../chapters_providers.dart';

/// Bölümler: haftalık anlatılar arasında yatay gezinme (en yeni önce).
class ChapterScreen extends ConsumerStatefulWidget {
  const ChapterScreen({super.key});

  @override
  ConsumerState<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends ConsumerState<ChapterScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chaptersAsync = ref.watch(chaptersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chaptersTitle)),
      body: SafeArea(
        child: chaptersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.chaptersLoadError('$e')),
            ),
          ),
          data: (chapters) {
            if (chapters.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.noChaptersYet, textAlign: TextAlign.center),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: chapters.length,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    itemBuilder: (context, index) =>
                        _ChapterPage(chapter: chapters[index]),
                  ),
                ),
                OnboardingProgressDots(
                  currentStep: _currentPage,
                  totalSteps: chapters.length,
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChapterPage extends ConsumerWidget {
  const _ChapterPage({required this.chapter});

  final Chapter chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('d.M.y');
    // Başlık + anlatı ham veriden, o anki dile göre canlı üretilir;
    // hiçbir yere kaydedilmez.
    final narrative = buildChapterNarrative(l10n, chapter);

    Goal? featuredGoal;
    if (chapter.mostImprovedGoalId != null) {
      final goals = ref.watch(goalsStreamProvider).value ?? const [];
      for (final goal in goals) {
        if (goal.id == chapter.mostImprovedGoalId) {
          featuredGoal = goal;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          l10n.chapterLabel(chapter.weekNumber),
          style: textTheme.labelSmall?.copyWith(
            letterSpacing: 2,
            color: scheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          narrative.title,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${dateFormat.format(chapter.startDate)} – '
          '${dateFormat.format(chapter.endDate)}',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(narrative.narrative, style: textTheme.bodyMedium),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                icon: Icons.star_outline,
                value: '${chapter.xpGainedThisWeek}',
                label: 'XP',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                icon: Icons.local_fire_department,
                value: l10n.daysCount(chapter.longestStreakThisWeek),
                label: l10n.longestStreakLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                icon: Icons.checklist,
                value: '${chapter.missionsCompletedThisWeek}',
                label: l10n.missionsStatLabel,
              ),
            ),
          ],
        ),
        if (chapter.mostImprovedGoalTitle != null &&
            chapter.mostImprovedGoalProgressDelta != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Hedef silinmiş olabilir; ikon bulunursa hedefinki,
                  // yoksa genel bayrak. Başlık her durumda ham veriden.
                  Icon(
                    featuredGoal?.icon ?? Icons.flag_outlined,
                    size: 20,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.featuredGoal(chapter.mostImprovedGoalTitle!),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    l10n.plusPercent(
                      (chapter.mostImprovedGoalProgressDelta! * 100).round(),
                    ),
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(height: 6),
            Text(value, style: textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
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
