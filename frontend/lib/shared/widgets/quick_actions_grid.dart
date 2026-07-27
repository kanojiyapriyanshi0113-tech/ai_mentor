import "package:flutter/material.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickAction({required this.label, required this.icon, required this.onTap});
}

/// Grid of icon + label tiles for the "Quick Actions" dashboard section.
class QuickActionsGrid extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 5
            : constraints.maxWidth >= 600
                ? 4
                : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (_, i) {
            final action = actions[i];
            return Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                onTap: action.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        child: Icon(action.icon, color: AppColors.primary, size: 20),
                      ),
                      SizedBox(height: AppSpacing.xs + 4),
                      Text(
                        action.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
