import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/router/app_router.dart';
import 'package:future_self/features/goals/data/goals_repository.dart';
import 'package:future_self/features/onboarding/presentation/onboarding_providers.dart';
import 'package:future_self/features/onboarding/presentation/screens/notifications_screen.dart';
import 'package:future_self/l10n/app_localizations.dart';

class MockGoalsRepository extends Mock implements GoalsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<UserMetricEntry>[]);
    registerFallbackValue(<Category>{});
  });

  testWidgets(
      '"Şimdi değil": hedefler kaydedilir, bayrak kapanır, dashboard açılır',
      (tester) async {
    final goalsRepository = MockGoalsRepository();
    when(() => goalsRepository.createGoalsFromOnboarding(any(), any()))
        .thenAnswer((_) async {});

    final router = GoRouter(
      initialLocation: AppRoutes.onboardingNotifications,
      routes: [
        GoRoute(
          path: AppRoutes.onboardingNotifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) =>
              const Scaffold(body: Text('dashboard-stub')),
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        goalsRepositoryProvider.overrideWithValue(goalsRepository),
      ],
    );
    addTearDown(container.dispose);
    container.read(onboardingInProgressProvider.notifier).start();

    await tester.pumpWidget(
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

    await tester.tap(find.text('Şimdi değil'));
    await tester.pumpAndSettle();

    verify(() => goalsRepository.createGoalsFromOnboarding(any(), any()))
        .called(1);
    expect(container.read(onboardingInProgressProvider), isFalse);
    expect(find.text('dashboard-stub'), findsOneWidget);
  });
}
