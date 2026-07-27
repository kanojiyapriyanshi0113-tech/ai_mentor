import "package:flutter/material.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";
import "animated_counter.dart";

/// One stat shown inside a [HeroSummaryCard].
/// Pass [value] as null when the backend doesn't expose this figure yet -
/// it renders as "-" instead of a fabricated number.
class HeroStatItem {
  final String label;
  final int? value;
  final IconData icon;
  final String prefix;
  final String suffix;

  const HeroStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.prefix = "",
    this.suffix = "",
  });
}

/// Gradient summary card at the top of Admin/Teacher dashboards:
/// a 2x2 stat grid plus a primary CTA button.
class HeroSummaryCard extends StatelessWidget {
  final List<HeroStatItem> stats;
  final String ctaLabel;
  final IconData ctaIcon;
  final VoidCallback onCtaTap;

  const HeroSummaryCard({
    super.key,
    required this.stats,
    required this.ctaLabel,
    required this.ctaIcon,
    required this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (_, i) {
              final stat = stats[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(stat.icon, color: Colors.white.withValues(alpha: 0.85), size: 18),
                  SizedBox(width: AppSpacing.xs + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        stat.value == null
                            ? const Text(
                                "-",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : AnimatedCounter(
                                value: stat.value!,
                                prefix: stat.prefix,
                                suffix: stat.suffix,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        Text(
                          stat.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCtaTap,
              icon: Icon(ctaIcon, size: 18),
              label: Text(ctaLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
