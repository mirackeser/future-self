import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/letters_repository.dart';
import '../letters_providers.dart';

/// Mektup açma ekranı: metin + yazılma tarihi; açılınca markOpened.
class LetterRevealScreen extends ConsumerStatefulWidget {
  const LetterRevealScreen({super.key, required this.letterId});

  final String letterId;

  @override
  ConsumerState<LetterRevealScreen> createState() =>
      _LetterRevealScreenState();
}

class _LetterRevealScreenState extends ConsumerState<LetterRevealScreen> {
  bool _markedOpened = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final lettersAsync = ref.watch(lettersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.letterTitle)),
      body: SafeArea(
        child: lettersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.letterLoadError('$e'))),
          data: (letters) {
            FutureLetter? letter;
            for (final l in letters) {
              if (l.id == widget.letterId) {
                letter = l;
                break;
              }
            }
            if (letter == null) {
              return Center(child: Text(l10n.letterNotFound));
            }
            if (!letter.isDelivered(DateTime.now())) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.letterStillSealed,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            _markOpenedOnce(letter);

            final monthsAgo = DateTime.now()
                    .difference(letter.createdAt)
                    .inDays ~/
                30;
            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Center(
                  child: Icon(Icons.drafts, size: 48, color: scheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  monthsAgo > 0
                      ? l10n.letterWrittenOnWithMonths(
                          DateFormat('d.M.y').format(letter.createdAt),
                          monthsAgo,
                        )
                      : l10n.letterWrittenOn(
                          DateFormat('d.M.y').format(letter.createdAt),
                        ),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(letter.text, style: textTheme.bodyLarge),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.lettersWrite),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.writeLetterToToday),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _markOpenedOnce(FutureLetter letter) {
    if (_markedOpened || letter.isOpened) return;
    _markedOpened = true;
    // Build sırasında yazma yapılmaz; ilk frame sonrasına ertelenir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lettersRepositoryProvider).markOpened(letter.id);
    });
  }
}
