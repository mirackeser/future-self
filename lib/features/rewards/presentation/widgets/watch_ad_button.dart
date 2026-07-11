import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/services.dart';
import '../../../../l10n/app_localizations.dart';

/// Ödüllü reklam akışını yürüten buton: basılınca reklamı yükleyip
/// gösterir, yüklenirken buton içinde spinner döner.
///
/// Ödül kazanılınca [onRewardEarned] çağrılır; döndürdüğü metin (null
/// değilse) SnackBar olarak gösterilir. Reklam yüklenemez ya da ödül
/// kazanılmadan kapatılırsa nazik bir hata SnackBar'ı gösterilir.
class WatchAdButton extends ConsumerStatefulWidget {
  const WatchAdButton({
    super.key,
    required this.label,
    required this.onRewardEarned,
  });

  final String label;
  final Future<String?> Function(WidgetRef ref) onRewardEarned;

  @override
  ConsumerState<WatchAdButton> createState() => _WatchAdButtonState();
}

class _WatchAdButtonState extends ConsumerState<WatchAdButton> {
  bool _busy = false;

  void _watchAd() {
    // Reklam kapandığında bu context unmounted olabilir; messenger ve
    // metinler async boşluktan önce yakalanır.
    final messenger = ScaffoldMessenger.of(context);
    final failureText = AppLocalizations.of(context)!.adRewardFailed;

    setState(() => _busy = true);
    ref.read(adsServiceProvider).loadAndShowRewardedAd(
      onRewardEarned: () async {
        final message = await widget.onRewardEarned(ref);
        if (mounted) setState(() => _busy = false);
        if (message != null) {
          messenger.showSnackBar(SnackBar(content: Text(message)));
        }
      },
      onAdFailedOrClosed: () {
        if (mounted) setState(() => _busy = false);
        messenger.showSnackBar(SnackBar(content: Text(failureText)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _busy ? null : _watchAd,
      child: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(widget.label),
    );
  }
}
