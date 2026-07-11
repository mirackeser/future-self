import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/model_labels.dart';
import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../onboarding_providers.dart';

/// Onboarding 3/4 — Mevcut durum girişi.
///
/// Seçilen her kategori için varsayılan metrikler hazır gelir; diğerleri
/// bottom sheet'ten eklenebilir. Tüm alanlar opsiyoneldir.
class CurrentStateScreen extends ConsumerWidget {
  const CurrentStateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(selectedCategoriesProvider);
    final sortedCategories = Category.values
        .where(categories.contains)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.currentStateTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.currentStateSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: sortedCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _CategoryMetricsCard(
                    category: sortedCategories[index],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () =>
                      context.go(AppRoutes.onboardingNotifications),
                  child: Text(l10n.continueButton),
                ),
              ),
              const SizedBox(height: 24),
              const OnboardingProgressDots(currentStep: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek bir kategorinin metrik girişlerini içeren kart.
class _CategoryMetricsCard extends ConsumerWidget {
  const _CategoryMetricsCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final entries = ref.watch(metricEntriesProvider);

    // Varsayılanlar her zaman görünür; eklenebilirler entry açılınca.
    final visibleTemplates = [
      ...MetricTemplates.defaultsFor(category),
      ...MetricTemplates.addableFor(category)
          .where((t) => entries.containsKey(t.id)),
    ];
    final remainingTemplates = MetricTemplates.addableFor(category)
        .where((t) => !entries.containsKey(t.id))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  category.localizedLabel(context),
                  style: textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final template in visibleTemplates) ...[
              _MetricInput(
                key: ValueKey(template.id),
                template: template,
                entry: entries[template.id],
              ),
              const SizedBox(height: 16),
            ],
            if (remainingTemplates.isNotEmpty)
              TextButton.icon(
                onPressed: () =>
                    _showAddMetricSheet(context, ref, remainingTemplates),
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.addMetric),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddMetricSheet(
    BuildContext context,
    WidgetRef ref,
    List<MetricTemplate> templates,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                AppLocalizations.of(sheetContext)!
                    .addMetricFor(category.localizedLabel(sheetContext)),
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final template in templates)
              ListTile(
                leading: Icon(category.icon),
                title: Text(template.localizedLabel(sheetContext)),
                subtitle:
                    template.unit != null ? Text(template.unit!) : null,
                onTap: () {
                  ref
                      .read(metricEntriesProvider.notifier)
                      .addTemplate(template.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Şablon tipine göre giriş alanları: numeric, level veya freeText.
class _MetricInput extends ConsumerWidget {
  const _MetricInput({super.key, required this.template, required this.entry});

  final MetricTemplate template;
  final UserMetricEntry? entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(metricEntriesProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          template.localizedLabel(context),
          style: textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        switch (template.type) {
          MetricType.numeric => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry?.currentValue,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.nowLabel,
                          suffixText: template.unit,
                        ),
                        onChanged: (v) =>
                            notifier.setCurrentValue(template.id, v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry?.targetValue,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.targetLabel,
                          suffixText: template.unit,
                        ),
                        onChanged: (v) =>
                            notifier.setTargetValue(template.id, v),
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
                  child: _LevelDropdown(
                    label: l10n.currentLevelLabel,
                    options: template.levelOptions,
                    value: entry?.currentValue,
                    onChanged: (v) =>
                        notifier.setCurrentValue(template.id, v ?? ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LevelDropdown(
                    label: l10n.targetLevelLabel,
                    options: template.levelOptions,
                    value: entry?.targetValue,
                    onChanged: (v) =>
                        notifier.setTargetValue(template.id, v ?? ''),
                  ),
                ),
              ],
            ),
          MetricType.freeText => TextFormField(
              initialValue: entry?.targetValue,
              decoration: InputDecoration(hintText: l10n.freeTextHint),
              onChanged: (v) => notifier.setTargetValue(template.id, v),
            ),
        },
      ],
    );
  }
}

class _LevelDropdown extends StatelessWidget {
  const _LevelDropdown({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: onChanged,
    );
  }
}
