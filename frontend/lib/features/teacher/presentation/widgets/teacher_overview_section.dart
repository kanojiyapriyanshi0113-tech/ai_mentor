import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../shared/widgets/stat_card.dart";
import "../../../../shared/widgets/retry_state.dart";
import "../providers/teacher_provider.dart";
import "../../../../core/models/teacher_models.dart";

/// Overview cards grid for the Teacher dashboard.
/// Reads directly from TeacherProvider.dashboard (TeacherDashboardModel) -
/// no separate API call, no separate model. Drop this into your teacher
/// dashboard screen wherever the "Overview Cards" section goes.
///
/// NOTE: TeacherDashboardModel has no PYQ/Assignment/Attendance count
/// fields yet, so those three cards show "-" instead of a real number.
/// Add total_pyqs / assignment + attendance counts to the backend
/// response and the matching fields to TeacherDashboardModel to make
/// them live.
class TeacherOverviewSection extends StatelessWidget {
  const TeacherOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        switch (provider.dashboardStatus) {
          case LoadStatus.error:
            return RetryState(
              message: provider.errorMessage ?? "Couldn't load your dashboard overview.",
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

  Widget _buildGrid(BuildContext context, {required bool loading, required TeacherDashboardModel? dashboard}) {
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
            itemCount: 10,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, _) => const StatCardSkeleton(),
          );
        }

        final cards = <StatCard>[
          StatCard(
            label: "Students",
            value: "${dashboard.totalStudents}",
            icon: Icons.groups_outlined,
          ),
          StatCard(
            label: "Batches",
            value: "${dashboard.totalBatches}",
            icon: Icons.layers_outlined,
          ),
          StatCard(
            label: "Subjects",
            value: "${dashboard.totalSubjects}",
            icon: Icons.subject_outlined,
          ),
          StatCard(
            label: "Chapters",
            value: "${dashboard.totalChapters}",
            icon: Icons.menu_book_outlined,
          ),
          StatCard(
            label: "Lectures",
            value: "${dashboard.totalLectures}",
            icon: Icons.play_circle_outline,
          ),
          StatCard(
            label: "PDFs",
            value: "${dashboard.totalPdfs}",
            icon: Icons.picture_as_pdf_outlined,
          ),
          StatCard(
            label: "Mock Tests",
            value: "${dashboard.totalMockTests}",
            icon: Icons.fact_check_outlined,
          ),
          // PYQs, Assignments, and Attendance have no backend field yet
          // (TeacherDashboardModel doesn't expose them) - shown honestly
          // as "-" rather than fabricated numbers.
          const StatCard(
            label: "PYQs",
            value: "-",
            icon: Icons.history_edu_outlined,
          ),
          const StatCard(
            label: "Assignments",
            value: "-",
            icon: Icons.assignment_outlined,
          ),
          const StatCard(
            label: "Attendance",
            value: "-",
            icon: Icons.fact_check_rounded,
          ),
          StatCard(
            label: "Live Classes",
            value: "${dashboard.upcomingLiveClasses.length}",
            icon: Icons.videocam_outlined,
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
