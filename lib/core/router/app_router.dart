import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/widgets.dart' show GlobalKey, NavigatorState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/chapters/presentation/screens/chapter_screen.dart';
import '../../features/coach/presentation/screens/coach_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/goals/presentation/screens/add_goal_screen.dart';
import '../../features/goals/presentation/screens/completed_goals_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/lessons/presentation/screens/lesson_comments_screen.dart';
import '../../features/lessons/presentation/screens/lessons_screen.dart';
import '../../features/letters/presentation/screens/letter_reveal_screen.dart';
import '../../features/letters/presentation/screens/letters_list_screen.dart';
import '../../features/letters/presentation/screens/write_letter_screen.dart';
import '../../features/missions/presentation/screens/mission_detail_screen.dart';
import '../../features/missions/presentation/screens/missions_screen.dart';
import '../../features/onboarding/presentation/screens/account_screen.dart';
import '../../features/onboarding/presentation/screens/categories_screen.dart';
import '../../features/onboarding/presentation/screens/current_state_screen.dart';
import '../../features/onboarding/presentation/screens/email_auth_screen.dart';
import '../../features/onboarding/presentation/onboarding_providers.dart';
import '../../features/onboarding/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import 'app_shell.dart';

/// Rota yolları — string tekrarını önlemek için tek yerde.
abstract final class AppRoutes {
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingCategories = '/onboarding/categories';
  static const String onboardingCurrentState = '/onboarding/current-state';
  static const String onboardingNotifications = '/onboarding/notifications';
  static const String onboardingAccount = '/onboarding/account';
  static const String onboardingAccountEmail = '/onboarding/account/email';
  static const String dashboard = '/dashboard';
  static const String missions = '/missions';
  static const String lessons = '/lessons';
  static const String coach = '/coach';
  static const String goalsAdd = '/goals/add';
  static const String goalsCompleted = '/goals/completed';
  static const String goalDetailPattern = '/goals/:id';
  static const String missionDetailPattern = '/missions/:id';
  static const String lessonCommentsPattern = '/lessons/:id';
  static const String chapters = '/chapters';
  static const String achievements = '/achievements';
  static const String letters = '/letters';
  static const String lettersWrite = '/letters/write';
  static const String letterRevealPattern = '/letters/:id';

  static String goalDetailPath(String goalId) => '/goals/$goalId';

  static String letterRevealPath(String letterId) => '/letters/$letterId';

  static String missionDetailPath(String missionId) => '/missions/$missionId';

  static String lessonCommentsPath(String lessonId) => '/lessons/$lessonId';
}

/// Kök navigator anahtarı — bildirim tıklamasından yönlendirme yapmak
/// için (bkz. LocalNotificationsService).
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// go_router yapılandırması.
///
/// Giriş kapısı hesap ekranıdır. Oturum kapalıyken sadece account
/// rotalarına girilebilir; oturum açıkken onboarding rotaları ancak
/// yeni-hesap akışı sürerken (onboardingInProgress) erişilebilir.
/// Auth veya akış durumu değişince redirect refreshListenable ile
/// yeniden değerlendirilir.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authStateChangesProvider, (_, _) => refreshNotifier.value++);
  ref.listen(onboardingInProgressProvider, (_, _) => refreshNotifier.value++);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.onboardingAccount,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final signedIn = ref.read(authStateChangesProvider).value != null;
      final onboardingInProgress = ref.read(onboardingInProgressProvider);
      final location = state.matchedLocation;
      final isAccountRoute = location == AppRoutes.onboardingAccount ||
          location == AppRoutes.onboardingAccountEmail;
      final inOnboarding =
          location == '/' || location.startsWith('/onboarding');

      if (!signedIn) {
        // Kapalı oturumda tek kapı hesap ekranı; kategori/mevcut durum/
        // bildirim ancak yeni-hesap akışının ortasında anlamlı.
        return isAccountRoute ? null : AppRoutes.onboardingAccount;
      }
      if (inOnboarding && !onboardingInProgress) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => AppRoutes.onboardingAccount,
      ),
      GoRoute(
        path: AppRoutes.onboardingWelcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingCategories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingCurrentState,
        builder: (context, state) => const CurrentStateScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingAccount,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingAccountEmail,
        builder: (context, state) => const EmailAuthScreen(),
      ),
      // Sabit '/goals/add' ve '/goals/completed', ':id' kalıbından
      // ÖNCE tanımlanmalı.
      GoRoute(
        path: AppRoutes.goalsAdd,
        builder: (context, state) => const AddGoalScreen(),
      ),
      GoRoute(
        path: AppRoutes.goalsCompleted,
        builder: (context, state) => const CompletedGoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.goalDetailPattern,
        builder: (context, state) =>
            GoalDetailScreen(goalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.missionDetailPattern,
        builder: (context, state) =>
            MissionDetailScreen(missionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.lessonCommentsPattern,
        builder: (context, state) =>
            LessonCommentsScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.chapters,
        builder: (context, state) => const ChapterScreen(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.letters,
        builder: (context, state) => const LettersListScreen(),
      ),
      // Sabit '/letters/write', ':id' kalıbından ÖNCE tanımlanmalı.
      GoRoute(
        path: AppRoutes.lettersWrite,
        builder: (context, state) => const WriteLetterScreen(),
      ),
      GoRoute(
        path: AppRoutes.letterRevealPattern,
        builder: (context, state) =>
            LetterRevealScreen(letterId: state.pathParameters['id']!),
      ),
      // Ana sekmeler: her branch kendi navigator'ıyla iç geçmişini korur.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.missions,
                builder: (context, state) => const MissionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.lessons,
                builder: (context, state) => const LessonsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.coach,
                builder: (context, state) => const CoachScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
