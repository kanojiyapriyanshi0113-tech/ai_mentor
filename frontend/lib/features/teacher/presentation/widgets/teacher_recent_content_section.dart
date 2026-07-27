import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/widgets/retry_state.dart";
import "../providers/teacher_provider.dart";

class _ContentRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContentRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent Content section for the Teacher dashboard.
///
/// Shows PDFs and Mock Tests from TeacherProvider (loaded via
/// provider.loadPdfs() / loadMockTests(), which call the real
/// GET /teacher/pdfs and GET /teacher/mocktests endpoints - these
/// already existed on the backend but weren't wired into the frontend
/// until now; no backend changes were made).
///
/// NOTE 1: "Recent Lectures" from the spec is NOT included here -
/// there is no GET /teacher/lectures (list) endpoint on the backend,
/// only create/update/delete. Add a list endpoint there to include it.
/// NOTE 2: PdfModel and MockTestModel have no createdAt/uploadedAt
/// field, so items are shown in the order the server returns them,
/// not guaranteed-sorted by recency. Add a timestamp field to both
/// entities to make "recent" accurate.
class TeacherRecentContentSection extends StatelessWidget {
  const TeacherRecentContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        if (provider.pdfsStatus == LoadStatus.error || provider.mockTestsStatus == LoadStatus.error) {
          return RetryState(
            message: provider.errorMessage ?? "Couldn't load recent content.",
            onRetry: () {
              provider.loadPdfs();
              provider.loadMockTests();
            },
          );
        }

        final recentPdfs = provider.pdfs.take(3).toList();
        final recentTests = provider.mockTests.take(3).toList();

        if (recentPdfs.isEmpty && recentTests.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "No PDFs or mock tests uploaded yet.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...recentPdfs.map((p) => _ContentRow(
                  icon: Icons.picture_as_pdf_outlined,
                  title: p.title,
                  subtitle: "PDF",
                )),
            ...recentTests.map((t) => _ContentRow(
                  icon: Icons.fact_check_outlined,
                  title: t.title,
                  subtitle: "Mock Test \u00b7 ${t.totalQuestions} questions",
                )),
          ],
        );
      },
    );
  }
}
