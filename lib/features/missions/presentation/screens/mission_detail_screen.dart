import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/missions_repository.dart';
import '../missions_providers.dart';

/// Mission detayı: notlar, tamamlama toggle'ı ve silme.
class MissionDetailScreen extends ConsumerWidget {
  const MissionDetailScreen({super.key, required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(missionsStreamProvider);

    return missionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(AppLocalizations.of(context)!.missionLoadError('$e')),
        ),
      ),
      data: (missions) {
        Mission? mission;
        for (final m in missions) {
          if (m.id == missionId) {
            mission = m;
            break;
          }
        }
        if (mission == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(AppLocalizations.of(context)!.missionNotFound),
            ),
          );
        }
        return _MissionDetailBody(mission: mission);
      },
    );
  }
}

class _MissionDetailBody extends ConsumerStatefulWidget {
  const _MissionDetailBody({required this.mission});

  final Mission mission;

  @override
  ConsumerState<_MissionDetailBody> createState() =>
      _MissionDetailBodyState();
}

class _MissionDetailBodyState extends ConsumerState<_MissionDetailBody> {
  final _noteController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sortedNotes = [...mission.notes]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(mission.icon, size: 32, color: scheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              mission.title,
              style: textTheme.headlineSmall?.copyWith(
                decoration:
                    mission.isCompleted ? TextDecoration.lineThrough : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.addedOn(DateFormat('d.M.y').format(mission.createdAt)),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: mission.isCompleted
                  ? OutlinedButton.icon(
                      onPressed: _busy ? null : () => _toggleCompleted(false),
                      icon: const Icon(Icons.undo),
                      label: Text(l10n.markIncomplete),
                    )
                  : FilledButton.icon(
                      onPressed: _busy ? null : () => _toggleCompleted(true),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.markCompleted),
                    ),
            ),
            const SizedBox(height: 24),
            Text(l10n.notesLabel, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: l10n.missionNoteHint,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _noteController.text.trim().isEmpty || _busy
                      ? null
                      : _addNote,
                  child: Text(l10n.addNote),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedNotes.isEmpty)
              Text(
                l10n.noNotesYet,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              for (final note in sortedNotes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.text, style: textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d.M.y HH:mm').format(note.timestamp),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(missionsRepositoryProvider)
          .addNote(widget.mission.id, _noteController.text);
      _noteController.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noteAddFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleCompleted(bool completed) async {
    setState(() => _busy = true);
    try {
      final repository = ref.read(missionsRepositoryProvider);
      if (completed) {
        await repository.markCompleted(widget.mission.id);
      } else {
        await repository.markIncomplete(widget.mission.id);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteMissionTitle),
        content: Text(l10n.deleteMissionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => _delete(dialogContext),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();
    try {
      await ref
          .read(missionsRepositoryProvider)
          .deleteMission(widget.mission.id);
      if (mounted) context.go(AppRoutes.missions);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.deleteFailed),
          ),
        );
      }
    }
  }
}
