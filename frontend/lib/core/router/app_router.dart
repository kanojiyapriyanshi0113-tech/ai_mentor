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
import "../../presentation/planner/planner_home_screen.dart";
import "../../presentation/practice/practice_screen.dart";
import "../../presentation/profile/profile_screen.dart";
import "../../presentation/settings/settings_screen.dart";
import "../../presentation/help/help_screen.dart";
import "../../presentation/upgrade_plan/upgrade_plan_screen.dart";
import "../../presentation/shell/main_shell_screen.dart";
import "../../features/teacher/presentation/screens/teacher_dashboard_screen.dart";
import "../../features/teacher/presentation/screens/teacher_profile_screen.dart";
import "../../features/teacher/presentation/screens/teacher_search_screen.dart";
import "../../features/teacher/presentation/screens/teacher_shell_screen.dart";
import "../../features/admin/presentation/screens/admin_dashboard_screen.dart";
import "../../features/admin/presentation/screens/admin_profile_screen.dart";
import "../../features/admin/presentation/screens/admin_search_screen.dart";
import "../../features/admin/presentation/screens/admin_shell_screen.dart";
import "../../shared/widgets/coming_soon_screen.dart";
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
      path: AppRoutes.aiPlanner,
      builder: (context, state) => const PlannerHomeScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return TeacherShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherDashboard,
              builder: (context, state) => const TeacherDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherContent,
              builder: (context, state) => const ComingSoonScreen(
                title: "Content",
                message: "A combined batches/subjects/chapters/lectures view will appear here "
                    "once the backend exposes list endpoints for a teacher's own content.",
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherStudents,
              builder: (context, state) => const ComingSoonScreen(
                title: "Students",
                message: "There is no endpoint yet for a teacher to list their own students.",
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherCalendar,
              builder: (context, state) => const ComingSoonScreen(
                title: "Calendar",
                message: "There is no endpoint yet listing all of a teacher's live classes by date.",
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherProfile,
              builder: (context, state) => const TeacherProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.teacherSearch,
      builder: (context, state) => const TeacherSearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.teacherNotifications,
      builder: (context, state) => const ComingSoonScreen(
        title: "Notifications",
        message: "There is no notification list/read/delete endpoint on the backend yet "
            "(only sending one exists). Add these routes to make this real.",
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdminShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminDashboard,
              builder: (context, state) => const AdminDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminManagement,
              builder: (context, state) => const ComingSoonScreen(
                title: "Management",
                message: "A combined teachers/students/subscriptions management hub will "
                    "appear here - each already has its own real screen reachable from "
                    "Quick Actions in the meantime.",
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminAnalytics,
              builder: (context, state) => const ComingSoonScreen(
                title: "Analytics",
                message: "A dedicated analytics view will appear here - the dashboard's "
                    "Analytics section already shows the real headline numbers available today.",
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminNotifications,
              builder: (context, state) => const ComingSoonScreen(
                title: "Notifications",
                message: "There is no notification list/read/delete endpoint on the backend "
                    "yet. Add these routes to make this real.",
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminProfile,
              builder: (context, state) => const AdminProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.adminSearch,
      builder: (context, state) => const AdminSearchScreen(),
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
