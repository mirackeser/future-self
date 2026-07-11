import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../lessons_providers.dart';
import '../widgets/add_lesson_sheet.dart';
import '../widgets/lesson_card.dart';

enum _LessonsTab { feed, saved }

/// Life Lessons: anonim topluluk akışı + kaydedilenler.
class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  _LessonsTab _tab = _LessonsTab.feed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lessonsAsync = ref.watch(
      _tab == _LessonsTab.feed ? lessonsFeedProvider : savedLessonsProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lifeLessons)),
      floatingActionButton: FloatingActionButton(
        // IndexedStack'te tüm sekmeler bellekte; varsayılan hero tag
        // çakışmasın diye benzersiz tag şart.
        heroTag: 'lessons_fab',
        onPressed: () => showAddLessonSheet(context),
        tooltip: l10n.share,
        child: const Icon(Icons.history_edu),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SegmentedButton<_LessonsTab>(
                segments: [
                  ButtonSegment(
                    value: _LessonsTab.feed,
                    label: Text(l10n.feedTab),
                  ),
                  ButtonSegment(
                    value: _LessonsTab.saved,
                    label: Text(l10n.savedTab),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (selection) =>
                    setState(() => _tab = selection.first),
              ),
            ),
            Expanded(
              child: lessonsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.lessonsLoadError('$e')),
                  ),
                ),
                data: (lessons) => lessons.isEmpty
                    ? _EmptyState(tab: _tab)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 88),
                        itemCount: lessons.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            LessonCard(lesson: lessons[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});

  final _LessonsTab tab;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab == _LessonsTab.feed
                  ? Icons.forum_outlined
                  : Icons.bookmark_border,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              tab == _LessonsTab.feed
                  ? l10n.noLessonsYet
                  : l10n.noSavedLessonsYet,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              tab == _LessonsTab.feed
                  ? l10n.noLessonsYetSubtitle
                  : l10n.noSavedLessonsYetSubtitle,
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
