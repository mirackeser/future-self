import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chapters/domain/chapter_generator.dart';
import '../../../chapters/presentation/chapters_providers.dart';
import '../../../goals/presentation/goals_providers.dart';
import '../../../letters/presentation/letters_providers.dart';
import '../../data/reflections_repository.dart';
import '../../domain/coach_engine.dart';
import '../../domain/daily_prompts.dart';
import '../../domain/reflection_questions.dart';
import '../coach_providers.dart';

/// Future Self Coach: kural tabanlı içgörüler + günlük yansıma sorusu.
///
/// Gerçek AI entegrasyonu geldiğinde kartların içeriği oradan gelecek;
/// ekran yapısı aynı kalacak.
class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coachTitle)),
      body: SafeArea(
        child: goalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.coachLoadError('$e')),
            ),
          ),
          data: (goals) {
            final progress =
                ref.watch(userProgressStreamProvider).value ??
                const UserProgress();
            final insights = buildInsights(l10n, goals, progress);
            final streak = insights.where(
              (i) => i.type == CoachInsightType.streakHighlight,
            );
            final neglected = insights.where(
              (i) => i.type == CoachInsightType.neglectedGoal,
            );
            final tips = insights.where(
              (i) => i.type == CoachInsightType.goalTip,
            );
            final empty = insights.where(
              (i) => i.type == CoachInsightType.empty,
            );

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                const _LatestChapterCard(),
                const _LettersEntryCard(),
                const _AchievementsEntryCard(),
                Text(
                  l10n.coachSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                for (final insight in empty) ...[
                  _InsightCard(
                    icon: Icons.flag_outlined,
                    message: insight.message,
                    background: scheme.surfaceContainerLow,
                    foreground: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                ],
                for (final insight in streak) ...[
                  _InsightCard(
                    icon: Icons.local_fire_department,
                    message: insight.message,
                    background: scheme.primaryContainer,
                    foreground: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                ],
                for (final insight in neglected) ...[
                  _InsightCard(
                    icon: Icons.notifications_none,
                    message: insight.message,
                    // Temanın "dikkat" tonu; alarm veren error tonu değil.
                    background: scheme.tertiaryContainer,
                    foreground: scheme.onTertiaryContainer,
                  ),
                  const SizedBox(height: 12),
                ],
                const _DailyPromptCard(),
                const SizedBox(height: 12),
                for (final insight in tips) ...[
                  _InsightCard(
                    icon: Icons.lightbulb_outline,
                    message: insight.message,
                    background: scheme.surfaceContainerLow,
                    foreground: scheme.onSurface,
                  ),
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

/// En son bölüme giriş noktası; hiç bölüm yoksa görünmez.
class _LatestChapterCard extends ConsumerWidget {
  const _LatestChapterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final chapters = ref.watch(chaptersStreamProvider).value ?? const [];
    if (chapters.isEmpty) return const SizedBox.shrink();
    final latest = chapters.first;
    // Başlık ham veriden, o anki dile göre canlı üretilir.
    final latestTitle = buildChapterNarrative(l10n, latest).title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
          onTap: () => context.push(AppRoutes.chapters),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.auto_stories, size: 20, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chapterEntryTitle(latest.weekNumber, latestTitle),
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.chapterEntrySubtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rozetler ve kişisel rekorlara giriş noktası.
class _AchievementsEntryCard extends StatelessWidget {
  const _AchievementsEntryCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
          onTap: () => context.push(AppRoutes.achievements),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 20, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.achievementsEntryTitle,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.achievementsEntrySubtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Future Self mektuplarına giriş: hiç mektup yoksa yazma daveti.
class _LettersEntryCard extends ConsumerWidget {
  const _LettersEntryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final letters = ref.watch(lettersStreamProvider).value ?? const [];
    final hasLetters = letters.isNotEmpty;
    final waitingCount = letters
        .where((l) => !l.isOpened && l.isDelivered(DateTime.now()))
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
          onTap: () => context.push(
            hasLetters ? AppRoutes.letters : AppRoutes.lettersWrite,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  hasLetters ? Icons.mail_outline : Icons.mail_lock,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLetters ? l10n.yourLetters : l10n.writeFirstLetter,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasLetters
                            ? (waitingCount > 0
                                  ? l10n.lettersWaiting(waitingCount)
                                  : l10n.lettersInJourney(letters.length))
                            : l10n.writeFirstLetterSubtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.message,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String message;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Günlük kart: tipe göre yansıma sorusu / söz / eylem ipucu.
///
/// Soru gününde mevcut Yanıtla/Düzenle akışı çalışır; söz ve ipucu
/// günlerinde kart salt bilgilendiricidir, yanıt kaydedilmez.
class _DailyPromptCard extends StatelessWidget {
  const _DailyPromptCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (todayPromptType()) {
      DailyPromptType.reflectionQuestion => const _ReflectionCard(),
      DailyPromptType.motivationalQuote => _InfoPromptCard(
        title: l10n.dailyQuoteTitle,
        icon: Icons.format_quote,
        text: quoteForToday(l10n),
      ),
      DailyPromptType.actionTip => _InfoPromptCard(
        title: l10n.dailyTipTitle,
        icon: Icons.lightbulb_outline,
        text: actionTipForToday(l10n),
      ),
    };
  }
}

/// Söz/ipucu günleri: aksiyonsuz bilgilendirici kart.
class _InfoPromptCard extends StatelessWidget {
  const _InfoPromptCard({
    required this.title,
    required this.icon,
    required this.text,
  });

  final String title;
  final IconData icon;
  final String text;

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
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(title, style: textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

/// Günlük yansıma sorusu: yanıtlanmamışsa Yanıtla, yanıtlanmışsa
/// yanıt + Düzenle.
class _ReflectionCard extends ConsumerWidget {
  const _ReflectionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final question = questionForToday(l10n);
    final reflection = ref.watch(todayReflectionProvider).value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.self_improvement, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(l10n.dailyQuestionTitle, style: textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(question, style: textTheme.titleSmall),
            const SizedBox(height: 12),
            if (reflection == null)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () => _openAnswerSheet(context, question, null),
                  child: Text(l10n.answerButton),
                ),
              )
            else ...[
              Text(
                l10n.todaysAnswer(reflection.answer),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      _openAnswerSheet(context, question, reflection.answer),
                  child: Text(l10n.edit),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openAnswerSheet(
    BuildContext context,
    String question,
    String? existingAnswer,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ReflectionAnswerSheet(
        question: question,
        existingAnswer: existingAnswer,
      ),
    );
  }
}

class _ReflectionAnswerSheet extends ConsumerStatefulWidget {
  const _ReflectionAnswerSheet({required this.question, this.existingAnswer});

  final String question;
  final String? existingAnswer;

  @override
  ConsumerState<_ReflectionAnswerSheet> createState() =>
      _ReflectionAnswerSheetState();
}

class _ReflectionAnswerSheetState
    extends ConsumerState<_ReflectionAnswerSheet> {
  late final TextEditingController _answerController = TextEditingController(
    text: widget.existingAnswer ?? '',
  );
  bool _busy = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.question, style: textTheme.titleSmall),
          const SizedBox(height: 12),
          TextField(
            controller: _answerController,
            autofocus: true,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.reflectionAnswerHint,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _answerController.text.trim().isEmpty || _busy
                  ? null
                  : _save,
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(reflectionsRepositoryProvider)
          .saveReflectionAnswer(
            ReflectionsRepository.dateKey(DateTime.now()),
            widget.question,
            _answerController.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)),
        );
      }
    }
  }
}
