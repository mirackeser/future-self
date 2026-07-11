import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/missions_repository.dart';

/// Yeni mission ekleme sheet'ini açar.
Future<void> showAddMissionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const AddMissionSheet(),
  );
}

/// Başlık + opsiyonel ikon seçici.
class AddMissionSheet extends ConsumerStatefulWidget {
  const AddMissionSheet({super.key});

  @override
  ConsumerState<AddMissionSheet> createState() => _AddMissionSheetState();
}

class _AddMissionSheetState extends ConsumerState<AddMissionSheet> {
  final _titleController = TextEditingController();
  String? _selectedIcon;
  bool _busy = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.missionTitleHint,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in MissionIcons.all.entries)
                _IconChoice(
                  icon: entry.value,
                  selected: _selectedIcon == entry.key,
                  onTap: () => setState(() {
                    _selectedIcon =
                        _selectedIcon == entry.key ? null : entry.key;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _titleController.text.trim().isEmpty || _busy
                  ? null
                  : _add,
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Future<void> _add() async {
    setState(() => _busy = true);
    try {
      await ref.read(missionsRepositoryProvider).createMission(
            title: _titleController.text,
            iconName: _selectedIcon,
          );
      if (mounted) Navigator.of(context).pop();
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

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 22,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
