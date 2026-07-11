import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// main() içinde gerçek SharedPreferences instance'ıyla override edilir;
/// böylece provider'lar tercihi senkron okuyabilir.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider main() içinde override edilmeli.',
  );
});

/// Desteklenen diller; ilki varsayılandır.
const supportedAppLocales = [Locale('tr'), Locale('en')];

/// Kullanıcının dil tercihi.
///
/// Kayıtlı tercih varsa o; yoksa sistem dili İngilizce ise en, diğer
/// tüm dillerde varsayılan tr. Değişiklik kalıcı olarak saklanır.
class LocaleNotifier extends Notifier<Locale> {
  static const String _prefsKey = 'app_locale';

  @override
  Locale build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_prefsKey);
    if (saved != null) {
      return supportedAppLocales.firstWhere(
        (l) => l.languageCode == saved,
        orElse: () => supportedAppLocales.first,
      );
    }
    final system = PlatformDispatcher.instance.locale;
    return system.languageCode == 'en'
        ? const Locale('en')
        : supportedAppLocales.first;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_prefsKey, locale.languageCode);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
