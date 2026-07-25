import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../presentation/splash/splash_screen.dart";
import "../../presentation/onboarding/onboarding_screen.dart";
import "../../presentation/auth/login_screen.dart";
import "../../presentation/auth/register_screen.dart";
import "../../presentation/auth/forgot_password_screen.dart";
import "../../presentation/exam_selection/exam_selection_screen.dart";
import "../../presentation/home/home_screen.dart";
import "../../presentation/courses/courses_screen.dart";
import "../../presentation/ai_mentor/ai_mentor_tab_screen.dart";
import "../../presentation/practice/practice_screen.dart";
import "../../presentation/profile/profile_screen.dart";
import "../../presentation/settings/settings_screen.dart";
import "../../presentation/help/help_screen.dart";
import "../../presentation/upgrade_plan/upgrade_plan_screen.dart";
import "../../presentation/shell/main_shell_screen.dart";
import "../../features/teacher/presentation/screens/teacher_dashboard_screen.dart";
import "../../features/admin/presentation/screens/admin_dashboard_screen.dart";
import "../navigation/navigation_service.dart";
import "app_routes.dart";

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.examSelection,
      builder: (context, state) => const ExamSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: AppRoutes.upgradePlan,
      builder: (context, state) => const UpgradePlanScreen(),
    ),
    GoRoute(
      path: AppRoutes.teacherDashboard,
      builder: (context, state) => const TeacherDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.courses,
              builder: (context, state) => const CoursesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.aiMentor,
              builder: (context, state) => const AIMentorTabScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.practice,
              builder: (context, state) => const PracticeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
