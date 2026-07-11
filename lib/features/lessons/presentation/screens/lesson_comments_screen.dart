import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/profanity_filter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/lessons_repository.dart';
import '../lessons_providers.dart';
import '../widgets/lesson_card.dart';

/// Bir lesson'ın yorumları: üstte özet kart, altta sabit yorum çubuğu.
class LessonCommentsScreen extends ConsumerStatefulWidget {
  const LessonCommentsScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonCommentsScreen> createState() =>
      _LessonCommentsScreenState();
}

class _LessonCommentsScreenState extends ConsumerState<LessonCommentsScreen> {
  final _commentController = TextEditingController();
  String? _errorMessage;
  bool _busy = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final lessonAsync = ref.watch(lessonProvider(widget.lessonId));
    final commentsAsync = ref.watch(lessonCommentsProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commentsTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  lessonAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text(l10n.lessonLoadError('$e')),
                    data: (lesson) => lesson == null
                        ? Text(l10n.lessonNotFound)
                        : LessonCard(
                            lesson: lesson,
                            compact: true,
                            onDeleted: () => context.go(AppRoutes.lessons),
                          ),
                  ),
                  const SizedBox(height: 16),
                  commentsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => Text(
                      l10n.commentsLoadError,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    data: (comments) => comments.isEmpty
                        ? Text(
                            l10n.noCommentsYet,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        : Column(
                            children: [
                              for (final comment in comments)
                                _CommentTile(
                                  comment: comment,
                                  lessonId: widget.lessonId,
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage!,
                    style: textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: l10n.commentHint,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _commentController.text.trim().isEmpty || _busy
                        ? null
                        : _send,
                    icon: const Icon(Icons.send),
                    tooltip: l10n.send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(lessonsRepositoryProvider)
          .addComment(widget.lessonId, _commentController.text);
      _commentController.clear();
    } on ProfanityException {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.profanityWarning;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              AppLocalizations.of(context)!.commentSendFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment, required this.lessonId});

  final LessonComment comment;
  final String lessonId;

  /// Sadece görsel amaçlı avatar harfi: yorum dokümanının rastgele
  /// id'sinden türetilir — authorUid'e hiç dokunulmaz, kullanıcı
  /// bilgisi sızmaz.
  String get _avatarLetter {
    const letters = 'ABCDEFGHIJKLMNOPRSTUVYZ';
    final index = comment.id.codeUnits.fold<int>(0, (a, b) => a + b);
    return letters[index % letters.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onLongPress: () => _confirmReport(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              child: Text(_avatarLetter, style: textTheme.labelSmall),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.text, style: textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    _timeAgo(
                      AppLocalizations.of(context)!,
                      comment.createdAt,
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReport(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmReportDialog(
      context,
      AppLocalizations.of(context)!.reportCommentConfirm,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(lessonsRepositoryProvider)
          .reportComment(lessonId, comment.id);
    } catch (_) {
      // Bildirim başarısız olsa da kullanıcıyı akıştan koparma.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reportThanks)),
      );
    }
  }

  /// Context'siz static; locale bilgisi [l10n] parametresiyle gelir.
  static String _timeAgo(AppLocalizations l10n, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
