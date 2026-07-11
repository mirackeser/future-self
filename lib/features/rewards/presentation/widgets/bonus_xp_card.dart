import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../goals/presentation/goals_providers.dart';
import '../../data/rewards_repository.dart';
import '../rewards_providers.dart';
import 'watch_ad_button.dart';

/// Dashboard kartı: günde bir kez, kısa bir reklam karşılığı bonus XP.
///
/// Bugün zaten kullanıldıysa buton yerine "Yarın tekrar gel" görünür.
/// Reklam desteklenmeyen platformlarda (web/desktop) hiç çizilmez.
class BonusXpCard extends ConsumerWidget {
  const BonusXpCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    if (!ref.watch(adsSupportedProvider)) return const SizedBox.shrink();
    final progress = ref.watch(userProgressStreamProvider).value;
    if (progress == null) return const SizedBox.shrink();

    final usedToday =
        progress.lastBonusXpAdDate == UserProgress.dayKey(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.card_giftcard, size: 24, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.bonusXpTitle, style: textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      l10n.bonusXpSubtitle(RewardsRepository.bonusXpAmount),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (usedToday)
                Text(
                  l10n.bonusXpComeBackTomorrow,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                WatchAdButton(
                  label: l10n.watchAdAction,
                  onRewardEarned: (ref) async {
                    final granted = await ref
                        .read(rewardsRepositoryProvider)
                        .claimDailyBonusXp();
                    return granted
                        ? l10n.bonusXpEarned(RewardsRepository.bonusXpAmount)
                        : null;
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
