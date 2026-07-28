import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../shared/widgets/stat_card.dart";
import "../../../../shared/widgets/retry_state.dart";
import "../providers/admin_provider.dart";
import "../../../../core/models/admin_models.dart";

/// Overview cards grid for the Admin dashboard.
/// Reads directly from AdminProvider.dashboard (AdminDashboardModel) -
/// no separate API call, no separate model. Drop this into your admin
/// dashboard screen wherever the "Overview Cards" section goes.
class AdminOverviewSection extends StatelessWidget {
  const AdminOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        switch (provider.dashboardStatus) {
          case LoadStatus.error:
            return RetryState(
              message: provider.errorMessage ?? "Couldn't load dashboard overview.",
              onRetry: provider.loadDashboard,
            );
          case LoadStatus.idle:
          case LoadStatus.loading:
            return _buildGrid(context, loading: true, dashboard: null);
          case LoadStatus.success:
            final dashboard = provider.dashboard;
            if (dashboard == null) {
              return const EmptyState(
                message: "No overview data available yet.",
                icon: Icons.dashboard_outlined,
              );
            }
            return _buildGrid(context, loading: false, dashboard: dashboard);
        }
      },
    );
  }

  Widget _buildGrid(BuildContext context, {required bool loading, required AdminDashboardModel? dashboard}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
                ? 3
                : 2;

        if (loading || dashboard == null) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, _) => const StatCardSkeleton(),
          );
        }

        final revenueRupees = dashboard.totalRevenuePaise / 100;
        final cards = <StatCard>[
          StatCard(
            label: "Total Students",
            value: "${dashboard.totalStudents}",
            icon: Icons.groups_outlined,
          ),
          StatCard(
            label: "Total Teachers",
            value: "${dashboard.totalTeachers}",
            icon: Icons.school_outlined,
          ),
          StatCard(
            label: "Active Batches",
            value: "${dashboard.activeBatches}",
            icon: Icons.layers_outlined,
          ),
          StatCard(
            label: "Revenue",
            value: "\u20b9${revenueRupees.toStringAsFixed(0)}",
            icon: Icons.currency_rupee_rounded,
          ),
          StatCard(
            label: "Active Subscriptions",
            value: "${dashboard.activeSubscriptions}",
            icon: Icons.workspace_premium_outlined,
          ),
          StatCard(
            label: "Live Classes",
            value: "${dashboard.upcomingLiveClasses}",
            icon: Icons.videocam_outlined,
          ),
          StatCard(
            label: "AI Usage Today",
            value: "${dashboard.aiUsageToday}",
            icon: Icons.auto_awesome_outlined,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (_, i) => cards[i],
        );
      },
    );
  }
}
