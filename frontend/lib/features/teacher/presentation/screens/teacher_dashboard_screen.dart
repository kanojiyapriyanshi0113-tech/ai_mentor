import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../core/widgets/app_card.dart";
import "../../../../core/widgets/app_page_padding.dart";
import "../../../../core/widgets/section_header.dart";
import "../providers/teacher_provider.dart";

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
      context.read<TeacherProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Dashboard")),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TeacherProvider>().loadDashboard(),
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

  Widget _buildBody(TeacherProvider provider) {
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
                onPressed: () => context.read<TeacherProvider>().loadDashboard(),
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
            _StatCard(label: "Batches", value: "${dashboard.totalBatches}", color: AppColors.info),
            _StatCard(label: "Subjects", value: "${dashboard.totalSubjects}", color: AppColors.success),
            _StatCard(label: "Chapters", value: "${dashboard.totalChapters}", color: AppColors.warning),
            _StatCard(label: "Lectures", value: "${dashboard.totalLectures}", color: AppColors.secondary),
            _StatCard(label: "Mock Tests", value: "${dashboard.totalMockTests}", color: AppColors.error),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(
          title: "Upcoming Live Classes",
          actionLabel: dashboard.upcomingLiveClasses.isEmpty ? null : "See all",
          onActionTap: dashboard.upcomingLiveClasses.isEmpty
              ? null
              : () {
                  // TODO: navigate to full live-classes list once that screen exists
                },
        ),
        const SizedBox(height: AppSpacing.md),
        if (dashboard.upcomingLiveClasses.isEmpty)
          AppCard(
            child: Text(
              "No live classes scheduled",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...dashboard.upcomingLiveClasses.map(
            (lc) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lc.title, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _formatScheduledAt(lc.scheduledAt),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatScheduledAt(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, "0");
    final period = local.hour >= 12 ? "PM" : "AM";
    return "${local.day}/${local.month}/${local.year} • $hour:$minute $period";
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
