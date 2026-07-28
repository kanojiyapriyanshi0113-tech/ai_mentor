import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../shared/widgets/stat_card.dart";
import "../providers/admin_provider.dart";

/// Content Statistics section for the Admin dashboard.
/// Reads AdminProvider.coursesReport (populated by provider.loadReports(),
/// already called from the dashboard screen's initState).
///
/// NOTE: CoursesReportModel has no PDF count field, so "PDFs" is omitted
/// here. Add total_pdfs to the courses report backend response and the
/// matching field to CoursesReportModel to include it.
class AdminContentStatisticsSection extends StatelessWidget {
  const AdminContentStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final report = provider.coursesReport;

        if (report == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "Loading content statistics...",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 900
                ? 5
                : constraints.maxWidth >= 600
                    ? 4
                    : 2;

            final cards = <StatCard>[
              StatCard(label: "Batches", value: "${report.totalBatches}", icon: Icons.layers_outlined),
              StatCard(label: "Subjects", value: "${report.totalSubjects}", icon: Icons.subject_outlined),
              StatCard(label: "Chapters", value: "${report.totalChapters}", icon: Icons.menu_book_outlined),
              StatCard(label: "Lectures", value: "${report.totalLectures}", icon: Icons.play_circle_outline),
              StatCard(label: "Mock Tests", value: "${report.totalMockTests}", icon: Icons.fact_check_outlined),
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
      },
    );
  }
}
