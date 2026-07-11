import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../goals/presentation/goals_providers.dart';
import '../../data/rewards_repository.dart';
import '../rewards_providers.dart';
import 'watch_ad_button.dart';

/// Kırık seri banner'ı: kırılmadan sonraki 48 saat içinde ve aylık
/// kurtarma hakkı varken, reklam izleyerek seriyi geri kazandırır.
///
/// "Şimdi değil" yalnızca bu oturumda gizler; pencere sürerken sonraki
/// açılışta yeniden görünür. Reklam desteklenmeyen platformlarda
/// çizilmez.
class StreakRestoreCard extends ConsumerWidget {
  const StreakRestoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    if (!ref.watch(adsSupportedProvider)) return const SizedBox.shrink();
    if (ref.watch(streakRestoreDismissedProvider)) {
      return const SizedBox.shrink();
    }
    final progress = ref.watch(userProgressStreamProvider).value;
    if (progress == null) return const SizedBox.shrink();

    // Ay devri sayacı okumadan önce uygulanır ki geçen aydan kalan
    // "hak doldu" durumu banner'ı yanlışlıkla gizlemesin.
    final now = DateTime.now();
    final refilled = UserProgress.refillFreezesIfNeeded(progress, now);
    if (!refilled.canRestoreStreak(now)) return const SizedBox.shrink();

    final days = refilled.previousStreakBeforeBreak;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 20,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.streakRestoreTitle(days),
                      style: textTheme.titleSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => ref
                        .read(streakRestoreDismissedProvider.notifier)
                        .dismiss(),
                    child: Text(l10n.notNow),
                  ),
                  WatchAdButton(
                    label: l10n.streakRestoreAction,
                    onRewardEarned: (ref) async {
                      final restored = await ref
                          .read(rewardsRepositoryProvider)
                          .restoreStreak();
                      return restored ? l10n.streakRestored(days) : null;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
