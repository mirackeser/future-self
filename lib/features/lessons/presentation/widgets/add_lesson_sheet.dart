import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/profanity_filter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/lessons_repository.dart';

/// Lesson paylaşma/düzenleme sheet'ini açar.
///
/// [existingLesson] doluysa sheet düzenleme modunda açılır: alanlar
/// önceden dolu gelir ve kayıt updateLesson ile yapılır.
Future<void> showAddLessonSheet(BuildContext context,
    {Lesson? existingLesson}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => AddLessonSheet(existingLesson: existingLesson),
  );
}

/// Anonim deneyim/pişmanlık paylaşımı: metin + kategori.
class AddLessonSheet extends ConsumerStatefulWidget {
  const AddLessonSheet({super.key, this.existingLesson});

  final Lesson? existingLesson;

  @override
  ConsumerState<AddLessonSheet> createState() => _AddLessonSheetState();
}

class _AddLessonSheetState extends ConsumerState<AddLessonSheet> {
  late final TextEditingController _textController =
      TextEditingController(text: widget.existingLesson?.text ?? '');
  late Category? _category = widget.existingLesson?.category;
  String? _errorMessage;
  bool _busy = false;

  bool get _isEditing => widget.existingLesson != null;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final canShare = _textController.text.trim().isNotEmpty &&
        _category != null &&
        !_busy;

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
          TextField(
            controller: _textController,
            autofocus: true,
            maxLines: 4,
            decoration: InputDecoration(hintText: l10n.lessonTextHint),
            onChanged: (_) => setState(() {}),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in Category.values)
                ChoiceChip(
                  label: Text(category.localizedLabel(context)),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.visibility_off_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.anonymousNotice,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: canShare ? _share : null,
              child: Text(_isEditing ? l10n.save : l10n.share),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Future<void> _share() async {
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(lessonsRepositoryProvider);
      if (_isEditing) {
        await repository.updateLesson(
          widget.existingLesson!.id,
          newText: _textController.text,
          newCategory: _category,
        );
      } else {
        await repository.createLesson(_textController.text, _category!);
      }
      if (mounted) Navigator.of(context).pop();
    } on ProfanityException {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.profanityWarning;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage = AppLocalizations.of(context)!.shareFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
