import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../core/models/admin_models.dart";
import "../../../../shared/widgets/retry_state.dart";
import "../providers/admin_provider.dart";

class _PlanTile extends StatelessWidget {
  final PlanCatalogModel plan;

  const _PlanTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final priceLabel = plan.isTrial ? "Free" : "\u20b9${(plan.pricePaise / 100).toStringAsFixed(0)}";
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          Icon(
            plan.isTrial ? Icons.card_giftcard_outlined : Icons.workspace_premium_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              plan.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          Text(
            "$priceLabel \u00b7 ${plan.durationDays}d",
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Subscription Overview section for the Admin dashboard.
///
/// Shows the actual plan catalog (Trial / Pro / Ultra / Ultra Max, etc.)
/// from AdminProvider.planCatalog (loaded via provider.loadPlanCatalog(),
/// which calls the existing shared GET /plans route).
///
/// NOTE: this is a list of plan TIERS, not a breakdown of how many
/// students are subscribed to each one - the backend's plan-catalog
/// response has no per-plan subscriber count. Add that field to make a
/// true "X students on Pro, Y on Ultra" breakdown possible.
class AdminSubscriptionOverviewSection extends StatelessWidget {
  const AdminSubscriptionOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.planCatalogStatus == LoadStatus.error) {
          return RetryState(
            message: provider.errorMessage ?? "Couldn't load subscription plans.",
            onRetry: provider.loadPlanCatalog,
          );
        }

        final plans = provider.planCatalog;

        if (provider.planCatalogStatus == LoadStatus.success && plans.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "No subscription plans configured yet.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        return Column(children: plans.map((p) => _PlanTile(plan: p)).toList());
      },
    );
  }
}
