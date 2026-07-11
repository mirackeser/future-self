import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/celebration_overlay.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/goals_repository.dart';

/// Hızlı ilerleme kaydı bottom sheet'ini açar (dashboard ve hedef
/// detayı aynı sheet'i kullanır).
Future<void> showQuickUpdateSheet(BuildContext context, Goal goal) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => QuickUpdateSheet(goal: goal),
  );
}

/// Tipe göre tek input / dropdown / işaretleme ile ilerleme kaydeder.
class QuickUpdateSheet extends ConsumerStatefulWidget {
  const QuickUpdateSheet({super.key, required this.goal});

  final Goal goal;

  @override
  ConsumerState<QuickUpdateSheet> createState() => _QuickUpdateSheetState();
}

class _QuickUpdateSheetState extends ConsumerState<QuickUpdateSheet> {
  late final TextEditingController _valueController = TextEditingController(
    text: widget.goal.currentValue?.toString() ?? '',
  );
  String? _selectedLevel;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.goal.currentLevel;
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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
          Text(goal.displayTitle(context), style: textTheme.titleMedium),
          const SizedBox(height: 16),
          switch (goal.type) {
            MetricType.numeric => TextField(
                controller: _valueController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.newValueLabel,
                  suffixText:
                      MetricTemplates.byId(goal.metricTemplateId).unit,
                ),
              ),
            MetricType.level => DropdownButtonFormField<String>(
                initialValue: _selectedLevel,
                isExpanded: true,
                decoration:
                    InputDecoration(labelText: l10n.currentLevelLabel),
                items: [
                  for (final option in MetricTemplates.byId(
                    goal.metricTemplateId,
                  ).levelOptions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (v) => setState(() => _selectedLevel = v),
              ),
            MetricType.freeText => Text(
                l10n.freeTextProgressQuestion,
                style: textTheme.bodyMedium,
              ),
          },
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(
                goal.type == MetricType.freeText
                    ? l10n.recordProgressWithXp(goal.xpReward)
                    : l10n.saveWithXp(goal.xpReward),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final goal = widget.goal;
    double? newValue;
    String? newLevel;

    if (goal.type == MetricType.numeric) {
      newValue =
          double.tryParse(_valueController.text.trim().replaceAll(',', '.'));
      if (newValue == null) return; // geçersiz giriş, sessizce bekle
    }
    if (goal.type == MetricType.level) {
      newLevel = _selectedLevel;
      if (newLevel == null) return;
    }

    setState(() => _busy = true);
    try {
      final justCompleted =
          await ref.read(goalsRepositoryProvider).updateGoalProgress(
                goal.id,
                newCurrentValue: newValue,
                newLevel: newLevel,
              );
      if (mounted) {
        // Kutlama pop'tan ÖNCE tetiklenir (context hâlâ mounted);
        // overlay kök seviyede olduğundan sheet kapansa da oynar.
        if (justCompleted) {
          CelebrationOverlay.celebrate(
            context,
            AppLocalizations.of(context)!.goalCompletedCelebration,
          );
        }
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveFailed),
          ),
        );
      }
    }
  }
}
