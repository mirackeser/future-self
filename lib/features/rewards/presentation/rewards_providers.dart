/// rewards özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/services.dart';

/// Reklam kartları bu platformda gösterilsin mi? (Yalnızca Android/iOS;
/// testlerde false/true override edilebilir.)
final adsSupportedProvider = Provider<bool>((ref) {
  return ref.watch(adsServiceProvider).isSupported;
});

/// Seri kurtarma banner'ı "Şimdi değil" ile bu oturumda gizlendi mi?
///
/// Bilinçli olarak Firestore'a yazılmaz: 48 saatlik pencere sürdüğü
/// müddetçe banner sonraki açılışta yeniden görünür.
final streakRestoreDismissedProvider =
    NotifierProvider<StreakRestoreDismissed, bool>(StreakRestoreDismissed.new);

class StreakRestoreDismissed extends Notifier<bool> {
  @override
  bool build() => false;

  void dismiss() => state = true;
}
