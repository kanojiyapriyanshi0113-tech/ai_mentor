import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/widgets/dashboard_card.dart";
import "../../../../shared/widgets/section_placeholder_card.dart";
import "../providers/admin_provider.dart";
import "../widgets/admin_overview_section.dart";
import "../widgets/admin_subscription_overview_section.dart";
import "../widgets/admin_analytics_section.dart";
import "../widgets/admin_content_statistics_section.dart";

/// Admin Analytics tab - "Reports & Statistics" only.
/// Home/action sections (Hero Card, Quick Actions, Recent Activity,
/// Pending Tasks, Live Classes, Recent Students, Recent Content) stay on
/// the Dashboard tab - see admin_dashboard_screen.dart.
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // This tab can be opened without visiting Dashboard first (indexedStack
    // shell branches), so it loads whatever the Dashboard screen used to
    // load for these sections - same provider methods, same guards.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.dashboardStatus == LoadStatus.idle) {
        provider.loadDashboard();
      }
      if (provider.teachersStatus == LoadStatus.idle) {
        provider.loadTeachers();
      }
      if (provider.planCatalogStatus == LoadStatus.idle) {
        provider.loadPlanCatalog();
      }
      // loadReports() has no status field to guard against duplicate
      // calls, but initState only runs once per screen instance, so
      // this still fires exactly once per visit.
      provider.loadReports();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AdminProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Analytics"), automaticallyImplyLeading: false),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.lg),
            children: [
              const DashboardSectionTitle(title: "Overview"),
              const AdminOverviewSection(),
              SizedBox(height: AppSpacing.xl),

              const DashboardSectionTitle(title: "Revenue Analytics"),
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

              // AdminAnalyticsSection above already renders a chart
              // placeholder under each tile - this section is for a
              // dedicated full-width charts view, which has no charting
              // library wired up yet.
              const DashboardSectionTitle(title: "Charts"),
              const SectionPlaceholderCard(
                title: "Charts",
                icon: Icons.show_chart_outlined,
                message: "Trend charts for revenue, enrollments, and engagement will appear here.",
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
