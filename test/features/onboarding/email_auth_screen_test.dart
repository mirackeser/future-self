import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/router/app_router.dart';
import 'package:future_self/core/services/auth_service.dart';
import 'package:future_self/features/goals/data/goals_repository.dart';
import 'package:future_self/features/onboarding/presentation/onboarding_providers.dart';
import 'package:future_self/features/onboarding/presentation/screens/email_auth_screen.dart';
import 'package:future_self/l10n/app_localizations.dart';

class MockAuthService extends Mock implements AuthService {}

class MockGoalsRepository extends Mock implements GoalsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<UserMetricEntry>[]);
    registerFallbackValue(<Category>{});
  });

  late MockAuthService authService;
  late MockGoalsRepository goalsRepository;
  late ProviderContainer container;

  setUp(() {
    authService = MockAuthService();
    goalsRepository = MockGoalsRepository();
    when(() => goalsRepository.createGoalsFromOnboarding(any(), any()))
        .thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester) {
    final router = GoRouter(
      initialLocation: AppRoutes.onboardingAccountEmail,
      routes: [
        GoRoute(
          path: AppRoutes.onboardingAccountEmail,
          builder: (context, state) => const EmailAuthScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboardingWelcome,
          builder: (context, state) =>
              const Scaffold(body: Text('welcome-stub')),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) =>
              const Scaffold(body: Text('dashboard-stub')),
        ),
      ],
    );

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        goalsRepositoryProvider.overrideWithValue(goalsRepository),
      ],
    );
    addTearDown(container.dispose);
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }

  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const ValueKey('emailField')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('passwordField')),
      'sifre123',
    );
  }

  testWidgets(
      'kayıt (isNewUser=true): karşılamaya gidiliyor, hedef kaydı henüz '
      'yapılmıyor, akış bayrağı açılıyor', (tester) async {
    when(() => authService.signUpWithEmail(any(), any()))
        .thenAnswer((_) async => true);
    await pumpScreen(tester);

    await fillForm(tester);
    await tester.tap(find.byKey(const ValueKey('submitButton')));
    await tester.pumpAndSettle();

    verify(() => authService.signUpWithEmail('test@example.com', 'sifre123'))
        .called(1);
    // Hedefler artık bildirim adımının sonunda yazılır.
    verifyNever(() => goalsRepository.createGoalsFromOnboarding(any(), any()));
    expect(find.text('welcome-stub'), findsOneWidget);
    expect(container.read(onboardingInProgressProvider), isTrue);
  });

  testWidgets(
      'giriş (isNewUser=false): hedef kaydı YAPILMADAN dashboard\'a '
      'gidiliyor', (tester) async {
    when(() => authService.signInWithEmail(any(), any()))
        .thenAnswer((_) async => false);
    await pumpScreen(tester);

    await tester.tap(find.text('Giriş yap'));
    await tester.pumpAndSettle();
    await fillForm(tester);
    await tester.tap(find.byKey(const ValueKey('submitButton')));
    await tester.pumpAndSettle();

    verify(() => authService.signInWithEmail(any(), any())).called(1);
    verifyNever(() => goalsRepository.createGoalsFromOnboarding(any(), any()));
    expect(find.text('dashboard-stub'), findsOneWidget);
    expect(container.read(onboardingInProgressProvider), isFalse);
  });

  testWidgets('giriş modunda hata mesajı gösterilip ekranda kalınıyor',
      (tester) async {
    when(() => authService.signInWithEmail(any(), any()))
        .thenThrow(const AuthFailure('E-posta veya şifre hatalı.'));
    await pumpScreen(tester);

    await tester.tap(find.text('Giriş yap'));
    await tester.pumpAndSettle();
    await fillForm(tester);
    await tester.tap(find.byKey(const ValueKey('submitButton')));
    await tester.pumpAndSettle();

    verify(() => authService.signInWithEmail(any(), any())).called(1);
    verifyNever(() => goalsRepository.createGoalsFromOnboarding(any(), any()));
    expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
    expect(find.text('dashboard-stub'), findsNothing);
  });

  testWidgets('boş alanlarla servis çağrılmıyor, uyarı gösteriliyor',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('submitButton')));
    await tester.pumpAndSettle();

    verifyZeroInteractions(authService);
    expect(find.text('E-posta ve şifreni gir.'), findsOneWidget);
  });
}
