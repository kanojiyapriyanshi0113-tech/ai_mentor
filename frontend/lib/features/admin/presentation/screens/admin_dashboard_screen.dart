import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../core/widgets/app_card.dart";
import "../../../../core/widgets/app_page_padding.dart";
import "../../../../core/widgets/section_header.dart";
import "../providers/admin_provider.dart";

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
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<AdminProvider>().loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppPagePadding(
              child: _buildBody(provider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.dashboardStatus == LoadStatus.loading && provider.dashboard == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.dashboardStatus == LoadStatus.error && provider.dashboard == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: Center(
          child: Column(
            children: [
              Text(provider.errorMessage ?? "Failed to load dashboard"),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => context.read<AdminProvider>().loadDashboard(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final dashboard = provider.dashboard;
    if (dashboard == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Overview"),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _StatCard(label: "Students", value: "${dashboard.totalStudents}", color: AppColors.primary),
            _StatCard(label: "Teachers", value: "${dashboard.totalTeachers}", color: AppColors.info),
            _StatCard(
              label: "Revenue",
              value: _formatPaise(dashboard.totalRevenuePaise),
              color: AppColors.success,
            ),
            _StatCard(label: "Active Subs", value: "${dashboard.activeSubscriptions}", color: AppColors.secondary),
            _StatCard(label: "Active Batches", value: "${dashboard.activeBatches}", color: AppColors.warning),
            _StatCard(label: "Live Classes", value: "${dashboard.upcomingLiveClasses}", color: AppColors.error),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeader(title: "AI Usage"),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${dashboard.aiUsageToday}", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text("AI questions asked today", style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeader(title: "Quick Actions"),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _QuickAction(label: "Teachers", icon: Icons.school_outlined, onTap: () {
              // TODO: navigate to admin teachers list
            }),
            _QuickAction(label: "Students", icon: Icons.people_outline, onTap: () {
              // TODO: navigate to admin students list
            }),
            _QuickAction(label: "Coupons", icon: Icons.local_offer_outlined, onTap: () {
              // TODO: navigate to admin coupons list
            }),
            _QuickAction(label: "Reports", icon: Icons.bar_chart_outlined, onTap: () {
              // TODO: navigate to admin reports
            }),
            _QuickAction(label: "Settings", icon: Icons.settings_outlined, onTap: () {
              // TODO: navigate to admin settings
            }),
          ],
        ),
      ],
    );
  }

  /// Formats a paise amount (Go int64, smallest currency unit) as INR.
  String _formatPaise(int paise) {
    final rupees = paise / 100;
    return "\u20b9${rupees.toStringAsFixed(0)}";
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
