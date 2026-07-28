import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:go_router/go_router.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../shared/widgets/dashboard_header.dart";
import "../../../../shared/widgets/section_placeholder_card.dart";
import "../../../../shared/widgets/quick_actions_grid.dart";
import "../../../../shared/widgets/hero_summary_card.dart";
import "../providers/teacher_provider.dart";
import "../widgets/teacher_overview_section.dart";
import "../widgets/live_classes_sections.dart";
import "../widgets/teacher_recent_content_section.dart";
import "../../../../shared/widgets/dashboard_card.dart";
import "../../../../core/providers/user_provider.dart";

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeacherProvider>();
      if (provider.dashboardStatus == LoadStatus.idle) {
        provider.loadDashboard();
      }
      if (provider.pdfsStatus == LoadStatus.idle) {
        provider.loadPdfs();
      }
      if (provider.mockTestsStatus == LoadStatus.idle) {
        provider.loadMockTests();
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<TeacherProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: Adjust `userProvider.name` below to match your actual
    // UserProvider field once confirmed - same assumption as the
    // Admin dashboard screen.
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.lg),
            children: [
              DashboardHeader(
                greeting: "Welcome Teacher",
                name: userProvider.currentUser?.name ?? "Teacher",
                role: "Teacher",
                onAvatarTap: () => context.push(AppRoutes.teacherProfile),
                onNotificationsTap: () => context.push(AppRoutes.teacherNotifications),
                onSearchTap: () => context.push(AppRoutes.teacherSearch),
              ),
              SizedBox(height: AppSpacing.xl),

              // NOTE: TeacherDashboardModel has no day-scoped lecture/live-
              // class counts or a pending-doubts field, so "Lectures" and
              // "Live Classes" here are totals/upcoming counts, not
              // "today's" as the spec named them - and "Pending Doubts"
              // has no backing field at all yet, shown as "-". Add these
              // to the backend + TeacherDashboardModel to make them accurate.
              Consumer<TeacherProvider>(
                builder: (context, provider, _) {
                  final d = provider.dashboard;
                  return HeroSummaryCard(
                    stats: [
                      HeroStatItem(
                        label: "Lectures",
                        value: d?.totalLectures,
                        icon: Icons.play_circle_outline,
                      ),
                      HeroStatItem(
                        label: "Live Classes",
                        value: d?.upcomingLiveClasses.length,
                        icon: Icons.videocam_outlined,
                      ),
                      const HeroStatItem(
                        label: "Pending Doubts",
                        value: null,
                        icon: Icons.help_outline_rounded,
                      ),
                      HeroStatItem(
                        label: "Total Students",
                        value: d?.totalStudents,
                        icon: Icons.groups_outlined,
                      ),
                    ],
                    ctaLabel: "Start Live Class",
                    ctaIcon: Icons.videocam_outlined,
                    onCtaTap: () {},
                  );
                },
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Overview"),
              const TeacherOverviewSection(),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Today's Schedule"),
              const DashboardCard(child: TodaysScheduleSection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Recent Students"),
              const SectionPlaceholderCard(
                title: "Recent Students",
                icon: Icons.person_add_alt_outlined,
                message: "Latest enrolled students will appear here.",
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Performance"),
              const SectionPlaceholderCard(
                title: "Performance",
                icon: Icons.insights_outlined,
                message: "Average progress, mock scores, and completion rate will appear here.",
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Upcoming Live Classes"),
              const DashboardCard(child: UpcomingLiveClassesSection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Recent Content"),
              const DashboardCard(child: TeacherRecentContentSection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Pending Tasks"),
              const SectionPlaceholderCard(
                title: "Pending Tasks",
                icon: Icons.checklist_outlined,
                message: "Draft lectures, pending PDFs, and unpublished tests will appear here.",
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Activity Timeline"),
              const SectionPlaceholderCard(
                title: "Activity Timeline",
                icon: Icons.history_outlined,
                message: "A timeline of your recent activity will appear here.",
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Quick Actions"),
              QuickActionsGrid(
                actions: [
                  QuickAction(label: "Batches", icon: Icons.layers_outlined, onTap: () {}),
                  QuickAction(label: "Subjects", icon: Icons.subject_outlined, onTap: () {}),
                  QuickAction(label: "Chapters", icon: Icons.menu_book_outlined, onTap: () {}),
                  QuickAction(label: "Lectures", icon: Icons.play_circle_outline, onTap: () {}),
                  QuickAction(label: "PDFs", icon: Icons.picture_as_pdf_outlined, onTap: () {}),
                  QuickAction(label: "Mock Tests", icon: Icons.fact_check_outlined, onTap: () {}),
                  QuickAction(label: "PYQs", icon: Icons.history_edu_outlined, onTap: () {}),
                  QuickAction(label: "Live Classes", icon: Icons.videocam_outlined, onTap: () {}),
                  QuickAction(label: "Notifications", icon: Icons.notifications_outlined, onTap: () {}),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
