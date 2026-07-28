import "package:flutter/material.dart";

import "../../../core/models/planner_model.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

const List<String> _kMonthShortNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

class PlanHistoryCard extends StatelessWidget {
  final PlannerPlan plan;
  final VoidCallback? onTap;

  const PlanHistoryCard({super.key, required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = plan.date;
    final formattedDate = "${date.day} ${_kMonthShortNames[date.month - 1]} ${date.year}";

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: Icon(
                  plan.isCompleted ? Icons.check_circle_rounded : Icons.event_note_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      plan.goal,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (plan.isCompleted)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

