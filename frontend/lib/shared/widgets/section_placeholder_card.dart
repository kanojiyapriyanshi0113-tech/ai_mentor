import "package:flutter/material.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

/// Wraps a dashboard section with a title and a "coming soon" body.
/// Swap the child of the real section in later without touching layout.
class SectionPlaceholderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const SectionPlaceholderCard({
    super.key,
    required this.title,
    required this.icon,
    this.message = "This section will appear here once connected.",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Icon(icon, size: 32, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title used above every dashboard section (overview, analytics, etc).
class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const DashboardSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

