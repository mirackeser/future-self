import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../letters_providers.dart';

/// Mektup listesi: mühürlü / teslim edilmiş (açılmayı bekleyen) / açılmış.
class LettersListScreen extends ConsumerWidget {
  const LettersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lettersAsync = ref.watch(lettersStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.yourLetters)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'letters_fab',
        onPressed: () => context.push(AppRoutes.lettersWrite),
        tooltip: l10n.writeLetterTooltip,
        child: const Icon(Icons.edit_outlined),
      ),
      body: SafeArea(
        child: lettersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.lettersLoadError('$e')),
            ),
          ),
          data: (letters) => letters.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 88),
                  itemCount: letters.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _LetterTile(letter: letters[index]),
                ),
        ),
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.letter});

  final FutureLetter letter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final delivered = letter.isDelivered(now);

    if (!delivered) {
      // Mühürlü: içerik gizli.
      final String subtitle;
      if (letter.deliveryMode == LetterDeliveryMode.fixedDate &&
          letter.deliveryDate != null) {
        final days = letter.deliveryDate!.difference(now).inDays;
        subtitle = days <= 0 ? l10n.opensToday : l10n.opensInDays(days);
      } else {
        subtitle = l10n.opensOnGoalCompletion;
      }
      return Card(
        child: ListTile(
          leading: Icon(Icons.mail_lock, color: scheme.onSurfaceVariant),
          title: Text(l10n.sealedLetter, style: textTheme.titleSmall),
          subtitle: Text(subtitle),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notYetTime)),
          ),
        ),
      );
    }

    if (!letter.isOpened) {
      // Teslim edildi, açılmayı bekliyor: parlak zarf.
      return Card(
        color: scheme.primaryContainer,
        child: ListTile(
          leading: Icon(Icons.mark_email_unread, color: scheme.primary),
          title: Text(
            l10n.letterArrivedTitle,
            style: textTheme.titleSmall?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          subtitle: Text(
            l10n.tapToOpen,
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
          onTap: () => context.push(AppRoutes.letterRevealPath(letter.id)),
        ),
      );
    }

    // Açılmış: normal satır.
    return Card(
      child: ListTile(
        leading: Icon(Icons.drafts_outlined, color: scheme.onSurfaceVariant),
        title: Text(
          letter.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium,
        ),
        subtitle: Text(DateFormat('d.M.y').format(letter.createdAt)),
        onTap: () => context.push(AppRoutes.letterRevealPath(letter.id)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noLettersYet,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noLettersYetSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
