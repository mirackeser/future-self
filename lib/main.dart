import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/local_notifications_service.dart';
import 'firebase_options.dart';

/// Bootstrap: Firebase + yerel bildirimler + tercihler + runApp.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Mektup bildirimleri: plugin/timezone init + soğuk açılışta bildirime
  // tıklanmışsa ilgili mektuba yönlendirme. İzin burada istenmez.
  await LocalNotificationsService.instance.init();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FutureSelfApp(),
    ),
  );
}
