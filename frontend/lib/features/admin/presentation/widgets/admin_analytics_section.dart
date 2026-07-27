import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../providers/admin_provider.dart";

class _AnalyticsTile extends StatelessWidget {
  final String label;
  final String value; // real headline number, or "-" when not available
  final IconData icon;

  const _AnalyticsTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs + 2),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          SizedBox(height: AppSpacing.xs + 2),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppSpacing.md),
          // Chart placeholder, per spec - no charting library wired yet.
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.xs + 2),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.show_chart_outlined, color: AppColors.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}

/// Analytics section for the Admin dashboard: real headline numbers where
/// AdminDashboardModel has them, with a chart placeholder body under each
/// (per spec - no charting data/library wired yet).
///
/// NOTE: "Registrations" has no backing field in AdminDashboardModel
/// (only totalStudents, a running total) - shown as "-".
class AdminAnalyticsSection extends StatelessWidget {
  const AdminAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final d = provider.dashboard;

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 600 ? 2 : 1);
            final tiles = [
              _AnalyticsTile(
                label: "Revenue",
                value: d != null ? "\u20b9${(d.totalRevenuePaise / 100).toStringAsFixed(0)}" : "-",
                icon: Icons.currency_rupee_rounded,
              ),
              const _AnalyticsTile(
                label: "Registrations",
                value: "-",
                icon: Icons.person_add_alt_outlined,
              ),
              _AnalyticsTile(
                label: "Subscriptions",
                value: d != null ? "${d.activeSubscriptions}" : "-",
                icon: Icons.workspace_premium_outlined,
              ),
              _AnalyticsTile(
                label: "AI Usage",
                value: d != null ? "${d.aiUsageToday}" : "-",
                icon: Icons.auto_awesome_outlined,
              ),
            ];

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: tiles,
            );
          },
        );
      },
    );
  }
}
