import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:future_self/app.dart';
import 'package:future_self/core/providers/locale_provider.dart';
import 'package:future_self/core/router/app_router.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/l10n/app_localizations.dart';
import 'package:future_self/features/auth/presentation/auth_providers.dart';
import 'package:future_self/features/onboarding/presentation/onboarding_providers.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  late ProviderContainer container;
  // Test cihazının sistem dili en; beklenen metinler için dili sabitle.
  final l10n = lookupAppLocalizations(const Locale('tr'));

  Future<void> pumpApp(WidgetTester tester, {bool signedIn = false}) async {
    SharedPreferences.setMockInitialValues(const {'app_locale': 'tr'});
    final sharedPreferences = await SharedPreferences.getInstance();

    User? user;
    MockFirebaseAuth? auth;

    if (signedIn) {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('u1');
      when(() => mockUser.displayName).thenReturn('Test');
      when(() => mockUser.email).thenReturn('test@example.com');
      user = mockUser;

      // Dashboard'ın build olabilmesi için Firebase yüzeyleri sahte.
      auth = MockFirebaseAuth();
      when(() => auth!.currentUser).thenReturn(mockUser);
    }

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        authStateChangesProvider.overrideWith(
          (ref) => Stream<User?>.value(user),
        ),
        if (auth != null)
          firebaseServiceProvider.overrideWithValue(
            FirebaseService(
              auth: auth,
              firestore: FakeFirebaseFirestore(),
              messaging: MockFirebaseMessaging(),
            ),
          ),
      ],
    );
    addTearDown(container.dispose);
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const FutureSelfApp(),
      ),
    );
  }

  GoRouter router() => container.read(appRouterProvider);

  testWidgets('oturum kapalıyken uygulama hesap ekranıyla açılıyor',
      (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountTitle), findsOneWidget);
  });

  testWidgets(
      'oturum kapalıyken onboarding ara adımları ve uygulama rotaları '
      'hesap ekranına yönlenir', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    router().go(AppRoutes.onboardingCategories);
    await tester.pumpAndSettle();
    expect(find.text(l10n.accountTitle), findsOneWidget);

    router().go(AppRoutes.dashboard);
    await tester.pumpAndSettle();
    expect(find.text(l10n.accountTitle), findsOneWidget);
  });

  testWidgets(
      'oturum açıkken (akış bayrağı kapalı) onboarding rotaları '
      "dashboard'a yönlenir", (tester) async {
    await pumpApp(tester, signedIn: true);
    await tester.pumpAndSettle();

    // Başlangıç rotası account'tu; redirect dashboard'a taşıdı.
    expect(find.text(l10n.noGoalsYet), findsOneWidget);

    router().go(AppRoutes.onboardingAccount);
    await tester.pumpAndSettle();
    expect(find.text(l10n.noGoalsYet), findsOneWidget);
  });

  testWidgets(
      'yeni hesap akışı sürerken onboarding adımları gezilebiliyor',
      (tester) async {
    await pumpApp(tester, signedIn: true);
    await tester.pumpAndSettle();

    container.read(onboardingInProgressProvider.notifier).start();
    router().go(AppRoutes.onboardingWelcome);
    await tester.pumpAndSettle();

    expect(find.text(l10n.welcomeTitle), findsOneWidget);

    await tester.tap(find.text(l10n.continueShort));
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoriesTitle), findsOneWidget);
  });
}
