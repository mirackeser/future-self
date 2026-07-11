import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ödüllü (rewarded) reklamlar: Bonus XP ve Seri Kurtarma.
///
/// Platform tespiti dart:io yerine [defaultTargetPlatform] ile yapılır —
/// web derlemesini bozmaz ve testlerde
/// [debugDefaultTargetPlatformOverride] ile değiştirilebilir.
class AdsService {
  bool _initialized = false;

  /// Google Mobile Ads yalnızca Android ve iOS'ta desteklenir.
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// SDK'yı bir kez başlatır; ilk reklam yüklemesinden önce çağrılır.
  Future<void> init() async {
    if (_initialized || !isSupported) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  /// Ödüllü reklam birimi.
  ///
  /// TODO(admob): Bunlar Google'ın TEST rewarded ad unit ID'leri.
  /// Production'a çıkmadan önce AdMob konsolundaki gerçek rewarded ad
  /// unit ID'leriyle (Android ve iOS için ayrı ayrı) değiştir.
  String get rewardedAdUnitId =>
      defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';

  /// Reklamı yükler ve yüklenir yüklenmez tam ekran gösterir.
  ///
  /// Kullanıcı ödülü hak ederse [onRewardEarned] bir kez çağrılır;
  /// reklam yüklenemez, gösterilemez ya da ödül kazanılmadan
  /// kapatılırsa [onAdFailedOrClosed] çağrılır. Çağıran taraf
  /// "yükleniyor" göstergesini iki durumda da kapatmalıdır.
  void loadAndShowRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdFailedOrClosed,
  }) {
    if (!isSupported) {
      onAdFailedOrClosed();
      return;
    }
    unawaited(
      init().then((_) {
        return RewardedAd.load(
          adUnitId: rewardedAdUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              var rewarded = false;
              ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  if (!rewarded) onAdFailedOrClosed();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  log(
                    'Rewarded reklam gösterilemedi: $error',
                    name: 'AdsService',
                  );
                  ad.dispose();
                  onAdFailedOrClosed();
                },
              );
              ad.show(
                onUserEarnedReward: (_, reward) {
                  rewarded = true;
                  onRewardEarned();
                },
              );
            },
            onAdFailedToLoad: (error) {
              log('Rewarded reklam yüklenemedi: $error', name: 'AdsService');
              onAdFailedOrClosed();
            },
          ),
        );
      }).catchError((Object e, StackTrace stackTrace) {
        log(
          'Reklam SDK başlatılamadı',
          name: 'AdsService',
          error: e,
          stackTrace: stackTrace,
        );
        onAdFailedOrClosed();
      }),
    );
  }
}

final adsServiceProvider = Provider<AdsService>((ref) => AdsService());
