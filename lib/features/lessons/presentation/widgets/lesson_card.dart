import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/lessons_repository.dart';
import '../lessons_providers.dart';
import 'add_lesson_sheet.dart';

/// Akış ve kaydedilenler listelerindeki anonim gönderi kartı.
class LessonCard extends ConsumerWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.compact = false,
    this.onDeleted,
  });

  final Lesson lesson;

  /// Yorum ekranındaki özet hali: aksiyon satırı gizlenir (yazarın
  /// düzenle/sil menüsü görünmeye devam eder).
  final bool compact;

  /// Silme başarılı olunca çağrılır (örn. yorum ekranı listeye döner).
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMine =
        ref.watch(firebaseServiceProvider).currentUser?.uid == lesson.authorUid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryChip(category: lesson.category),
                const Spacer(),
                if (!compact || isMine)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    onSelected: (value) => switch (value) {
                      'edit' => showAddLessonSheet(
                          context,
                          existingLesson: lesson,
                        ),
                      'delete' => _confirmDelete(context, ref),
                      _ => _confirmReport(context, ref),
                    },
                    itemBuilder: (_) {
                      final l10n = AppLocalizations.of(context)!;
                      return isMine
                          ? [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(l10n.edit),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l10n.delete),
                              ),
                            ]
                          : [
                              PopupMenuItem(
                                value: 'report',
                                child: Text(l10n.report),
                              ),
                            ];
                    },
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: compact ? 8 : 0),
              child: Text(
                lesson.text,
                style: textTheme.bodyMedium,
                maxLines: compact ? 4 : null,
                overflow: compact ? TextOverflow.ellipsis : null,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _LikeButton(lesson: lesson),
                  const SizedBox(width: 16),
                  _SaveButton(lesson: lesson),
                  const SizedBox(width: 16),
                  _ActionIcon(
                    icon: Icons.mode_comment_outlined,
                    count: lesson.commentCount,
                    color: scheme.onSurfaceVariant,
                    onTap: () =>
                        context.push(AppRoutes.lessonCommentsPath(lesson.id)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteLessonTitle),
        content: Text(l10n.deleteLessonConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(lessonsRepositoryProvider).deleteLesson(lesson.id);
      onDeleted?.call();
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

  Future<void> _confirmReport(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmReportDialog(
      context,
      AppLocalizations.of(context)!.reportLessonConfirm,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(lessonsRepositoryProvider).reportLesson(lesson.id);
    } catch (_) {
      // Bildirim başarısız olsa da kullanıcıyı akıştan koparma.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reportThanks)),
      );
    }
  }
}

/// Bildir onayı — gönderi ve yorum akışları aynı dialog'u kullanır.
Future<bool?> showConfirmReportDialog(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.report),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.report),
        ),
      ],
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category.localizedLabel(context),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
      ),
    );
  }
}

class _LikeButton extends ConsumerWidget {
  const _LikeButton({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isLiked = ref.watch(isLikedProvider(lesson.id)).value ?? false;

    return _ActionIcon(
      icon: isLiked ? Icons.favorite : Icons.favorite_border,
      count: lesson.likeCount,
      color: isLiked ? scheme.primary : scheme.onSurfaceVariant,
      onTap: () =>
          ref.read(lessonsRepositoryProvider).toggleLike(lesson.id),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  const _SaveButton({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isSaved = ref.watch(isSavedProvider(lesson.id)).value ?? false;

    return _ActionIcon(
      icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
      count: lesson.saveCount,
      color: isSaved ? scheme.primary : scheme.onSurfaceVariant,
      onTap: () =>
          ref.read(lessonsRepositoryProvider).toggleSave(lesson.id),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
