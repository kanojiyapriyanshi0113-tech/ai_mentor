import "package:flutter/material.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

/// Bordered card wrapper matching SectionPlaceholderCard's look, used to
/// wrap real (data-backed) dashboard section content instead of a placeholder.
class DashboardCard extends StatelessWidget {
  final Widget child;

  const DashboardCard({super.key, required this.child});

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
      child: child,
    );
  }
}
