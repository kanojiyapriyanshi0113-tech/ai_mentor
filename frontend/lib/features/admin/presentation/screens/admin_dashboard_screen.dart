import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/widgets/dashboard_header.dart";
import "../../../../shared/widgets/section_placeholder_card.dart";
import "../../../../shared/widgets/quick_actions_grid.dart";
import "../../../../shared/widgets/hero_summary_card.dart";
import "../providers/admin_provider.dart";
import "../widgets/admin_overview_section.dart";
import "../widgets/admin_subscription_overview_section.dart";
import "../widgets/admin_analytics_section.dart";
import "../widgets/admin_content_statistics_section.dart";
import "../widgets/admin_pending_actions_section.dart";
import "../widgets/admin_recent_activity_section.dart";
import "../../../../shared/widgets/dashboard_card.dart";
import "../../../../core/providers/user_provider.dart";

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.dashboardStatus == LoadStatus.idle) {
        provider.loadDashboard();
      }
      if (provider.teachersStatus == LoadStatus.idle) {
        provider.loadTeachers();
      }
      if (provider.paymentsStatus == LoadStatus.idle) {
        provider.loadPayments();
      }
      // loadReports() has no status field to guard against duplicate
      // calls, but initState only runs once per screen instance, so
      // this still fires exactly once per visit.
      provider.loadReports();
      if (provider.planCatalogStatus == LoadStatus.idle) {
        provider.loadPlanCatalog();
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AdminProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: Adjust `userProvider.name` below to match your actual
    // UserProvider field once confirmed - this is the one assumption
    // in this screen I could not verify against your codebase.
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
                greeting: "Welcome Admin",
                name: userProvider.currentUser?.name ?? "Admin",
                role: "Admin",
                onAvatarTap: () {},
                onNotificationsTap: () {},
                onSearchTap: () {},
              ),
              SizedBox(height: AppSpacing.xl),

              // NOTE: AdminDashboardModel has no day-scoped revenue or new-
              // student-count fields, so "Revenue" and "Teachers" here are
              // totals, not "today's revenue" / "active teachers" as the
              // spec named them - and "New Students" has no backing field
              // at all yet, shown as "-". Add the fields to the backend +
              // AdminDashboardModel to make these accurate.
              Consumer<AdminProvider>(
                builder: (context, provider, _) {
                  final d = provider.dashboard;
                  return HeroSummaryCard(
                    stats: [
                      HeroStatItem(
                        label: "Revenue",
                        value: d != null ? (d.totalRevenuePaise / 100).round() : null,
                        icon: Icons.currency_rupee_rounded,
                        prefix: "\u20b9",
                      ),
                      const HeroStatItem(
                        label: "New Students",
                        value: null,
                        icon: Icons.person_add_alt_1_outlined,
                      ),
                      HeroStatItem(
                        label: "Teachers",
                        value: d?.totalTeachers,
                        icon: Icons.school_outlined,
                      ),
                      HeroStatItem(
                        label: "Active Subscriptions",
                        value: d?.activeSubscriptions,
                        icon: Icons.workspace_premium_outlined,
                      ),
                    ],
                    ctaLabel: "View Reports",
                    ctaIcon: Icons.bar_chart_outlined,
                    onCtaTap: () {},
                  );
                },
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Overview"),
              const AdminOverviewSection(),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Analytics"),
              const DashboardCard(child: AdminAnalyticsSection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Subscription Overview"),
              const DashboardCard(child: AdminSubscriptionOverviewSection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Content Statistics"),
              const DashboardCard(child: AdminContentStatisticsSection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Teacher Performance"),
              const SectionPlaceholderCard(
                title: "Teacher Performance",
                icon: Icons.leaderboard_outlined,
                message: "Per-teacher students, courses, and ratings will appear here.",
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Pending Actions"),
              const DashboardCard(child: AdminPendingActionsSection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Recent Activity"),
              const DashboardCard(child: AdminRecentActivitySection()),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Quick Actions"),
              QuickActionsGrid(
                actions: [
                  QuickAction(label: "Teachers", icon: Icons.school_outlined, onTap: () {}),
                  QuickAction(label: "Students", icon: Icons.groups_outlined, onTap: () {}),
                  QuickAction(label: "Subscriptions", icon: Icons.workspace_premium_outlined, onTap: () {}),
                  QuickAction(label: "Coupons", icon: Icons.confirmation_number_outlined, onTap: () {}),
                  QuickAction(label: "Payments", icon: Icons.payments_outlined, onTap: () {}),
                  QuickAction(label: "Reports", icon: Icons.bar_chart_outlined, onTap: () {}),
                  QuickAction(label: "Settings", icon: Icons.settings_outlined, onTap: () {}),
                  QuickAction(label: "Banner", icon: Icons.image_outlined, onTap: () {}),
                ],
              ),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "System Status"),
              const SectionPlaceholderCard(
                title: "System Status",
                icon: Icons.dns_outlined,
                message: "Database, storage, AI service, payments, and API health will appear here.",
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
