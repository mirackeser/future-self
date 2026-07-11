import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/goals_repository.dart';
import '../goals_providers.dart';

/// Manuel hedef ekleme: kategori → şablon → değerler (3 içsel adım).
class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  int _step = 0;
  Category? _category;
  MetricTemplate? _template;

  final _currentController = TextEditingController();
  final _targetController = TextEditingController();
  String? _currentLevel;
  String? _targetLevel;
  bool _busy = false;

  @override
  void dispose() {
    _currentController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  bool get _hasAnyValue {
    final template = _template;
    if (template == null) return false;
    return switch (template.type) {
      MetricType.numeric => _currentController.text.trim().isNotEmpty ||
          _targetController.text.trim().isNotEmpty,
      MetricType.level => _currentLevel != null || _targetLevel != null,
      MetricType.freeText => _targetController.text.trim().isNotEmpty,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addGoalTitle),
        // Adım içindeyken geri oku adımı geriletir, ilk adımda rotayı
        // kapatır.
        leading: _step == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              ),
      ),
      body: SafeArea(
        child: switch (_step) {
          0 => _CategoryStep(
              onSelected: (category) => setState(() {
                _category = category;
                _step = 1;
              }),
            ),
          1 => _TemplateStep(
              category: _category!,
              onSelected: (template) => setState(() {
                _template = template;
                _currentController.clear();
                _targetController.clear();
                _currentLevel = null;
                _targetLevel = null;
                _step = 2;
              }),
            ),
          _ => _valuesStep(context),
        },
      ),
    );
  }

  Widget _valuesStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final template = _template!;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(template.localizedLabel(context), style: textTheme.titleMedium),
        const SizedBox(height: 16),
        switch (template.type) {
          MetricType.numeric => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _currentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.nowLabel,
                          suffixText: template.unit,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _targetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.targetLabel,
                          suffixText: template.unit,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                if (template.direction == MetricDirection.decreasing)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.decreasingHint,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          MetricType.level => Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _currentLevel,
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: l10n.currentLevelLabel),
                    items: [
                      for (final option in template.levelOptions)
                        DropdownMenuItem(value: option, child: Text(option)),
                    ],
                    onChanged: (v) => setState(() => _currentLevel = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _targetLevel,
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: l10n.targetLevelLabel),
                    items: [
                      for (final option in template.levelOptions)
                        DropdownMenuItem(value: option, child: Text(option)),
                    ],
                    onChanged: (v) => setState(() => _targetLevel = v),
                  ),
                ),
              ],
            ),
          MetricType.freeText => TextField(
              controller: _targetController,
              decoration: InputDecoration(hintText: l10n.freeTextHint),
              onChanged: (_) => setState(() {}),
            ),
        },
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: _hasAnyValue && !_busy ? _submit : null,
            child: Text(l10n.addGoalSubmit),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final template = _template!;
    String? normalize(String value) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final entry = switch (template.type) {
      MetricType.numeric => UserMetricEntry(
          templateId: template.id,
          currentValue: normalize(_currentController.text),
          targetValue: normalize(_targetController.text),
        ),
      MetricType.level => UserMetricEntry(
          templateId: template.id,
          currentValue: _currentLevel,
          targetValue: _targetLevel,
        ),
      MetricType.freeText => UserMetricEntry(
          templateId: template.id,
          targetValue: normalize(_targetController.text),
        ),
    };

    setState(() => _busy = true);
    try {
      await ref
          .read(goalsRepositoryProvider)
          .createSingleGoal(template: template, entry: entry);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.goalAdded)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.addFailed)),
        );
      }
    }
  }
}

/// Adım 1: tek seçimli kategori grid'i.
class _CategoryStep extends StatelessWidget {
  const _CategoryStep({required this.onSelected});

  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.whichArea,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                for (final category in Category.values)
                  Material(
                    color: scheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: InkWell(
                      onTap: () => onSelected(category),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category.icon,
                              size: 28, color: scheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            category.localizedLabel(context),
                            style: textTheme.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Adım 2: kategori şablonları; zaten hedefi olanlar pasif.
class _TemplateStep extends ConsumerWidget {
  const _TemplateStep({required this.category, required this.onSelected});

  final Category category;
  final ValueChanged<MetricTemplate> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final goals = ref.watch(goalsStreamProvider).value ?? const [];
    final usedTemplateIds = {for (final goal in goals) goal.metricTemplateId};
    final templates = [
      ...MetricTemplates.defaultsFor(category),
      ...MetricTemplates.addableFor(category),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          l10n.pickMetricFor(category.localizedLabel(context)),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        for (final template in templates) ...[
          Opacity(
            opacity: usedTemplateIds.contains(template.id) ? 0.5 : 1,
            child: Card(
              child: ListTile(
                enabled: !usedTemplateIds.contains(template.id),
                title: Text(template.localizedLabel(context)),
                subtitle: template.unit != null
                    ? Text(template.unit!)
                    : (template.type == MetricType.freeText
                        ? Text(l10n.freeTextType)
                        : null),
                trailing: usedTemplateIds.contains(template.id)
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.alreadyAdded,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_right, size: 20),
                onTap: usedTemplateIds.contains(template.id)
                    ? null
                    : () => onSelected(template),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
