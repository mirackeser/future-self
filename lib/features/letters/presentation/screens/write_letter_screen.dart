import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../goals/presentation/goals_providers.dart';
import '../../data/letters_repository.dart';

/// Teslim seçenekleri: sabit süreler + hedef tamamlanınca.
enum _DeliveryChoice { oneMonth, threeMonths, sixMonths, onGoalCompletion }

/// Gelecekteki kendine mektup yazma ekranı.
class WriteLetterScreen extends ConsumerStatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  ConsumerState<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends ConsumerState<WriteLetterScreen> {
  final _textController = TextEditingController();
  _DeliveryChoice? _choice;
  String? _selectedGoalId;
  bool _busy = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canSeal {
    if (_textController.text.trim().isEmpty || _busy) return false;
    if (_choice == null) return false;
    if (_choice == _DeliveryChoice.onGoalCompletion) {
      return _selectedGoalId != null;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.letterToFuture)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: InputDecoration(hintText: l10n.letterHint),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(l10n.whenToDeliver, style: textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _choiceChip(_DeliveryChoice.oneMonth, l10n.inOneMonth),
                _choiceChip(_DeliveryChoice.threeMonths, l10n.inThreeMonths),
                _choiceChip(_DeliveryChoice.sixMonths, l10n.inSixMonths),
                _choiceChip(
                  _DeliveryChoice.onGoalCompletion,
                  l10n.onGoalCompletionChip,
                ),
              ],
            ),
            if (_choice == _DeliveryChoice.onGoalCompletion) ...[
              const SizedBox(height: 12),
              _GoalPicker(
                selectedGoalId: _selectedGoalId,
                onChanged: (id) => setState(() => _selectedGoalId = id),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.lock_outline, size: 16,
                    color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.letterSealNote,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _canSeal ? _seal : null,
                icon: const Icon(Icons.mail_lock),
                label: Text(l10n.sealLetter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceChip(_DeliveryChoice choice, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _choice == choice,
      onSelected: (_) => setState(() => _choice = choice),
    );
  }

  Future<void> _seal() async {
    setState(() => _busy = true);
    try {
      // İzin sadece bu özellik için, mühürleme anında istenir.
      await ref.read(localNotificationsServiceProvider).requestPermission();

      final now = DateTime.now();
      final repository = ref.read(lettersRepositoryProvider);
      switch (_choice!) {
        case _DeliveryChoice.oneMonth:
        case _DeliveryChoice.threeMonths:
        case _DeliveryChoice.sixMonths:
          final months = switch (_choice!) {
            _DeliveryChoice.oneMonth => 1,
            _DeliveryChoice.threeMonths => 3,
            _ => 6,
          };
          await repository.createLetter(
            text: _textController.text,
            deliveryMode: LetterDeliveryMode.fixedDate,
            deliveryDate: DateTime(
              now.year,
              now.month + months,
              now.day,
              now.hour,
              now.minute,
            ),
          );
        case _DeliveryChoice.onGoalCompletion:
          await repository.createLetter(
            text: _textController.text,
            deliveryMode: LetterDeliveryMode.goalCompletion,
            relatedGoalId: _selectedGoalId,
          );
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.letterSealed),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.sealFailed),
          ),
        );
      }
    }
  }
}

/// Aktif hedeflerden birini seçtiren liste.
class _GoalPicker extends ConsumerWidget {
  const _GoalPicker({required this.selectedGoalId, required this.onChanged});

  final String? selectedGoalId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final goals = ref.watch(goalsStreamProvider).value ?? const [];
    final active =
        goals.where((g) => (g.progressPercent ?? 0) < 1.0).toList();

    if (active.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noActiveGoalForLetter,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      );
    }

    return Column(
      children: [
        for (final goal in active)
          RadioListTile<String>(
            value: goal.id,
            // ignore: deprecated_member_use
            groupValue: selectedGoalId,
            // ignore: deprecated_member_use
            onChanged: onChanged,
            dense: true,
            title: Text(goal.displayTitle(context)),
            secondary: Icon(goal.icon, size: 20, color: scheme.primary),
          ),
      ],
    );
  }
}
