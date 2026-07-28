import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../providers/admin_provider.dart";

String _formatDate(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, "0");
  final m = dt.minute.toString().padLeft(2, "0");
  return "${dt.day}/${dt.month} $h:$m";
}

/// Recent Activity section for the Admin dashboard.
///
/// Shows real recent payments (AdminProvider.payments, loaded via
/// provider.loadPayments(), already called from the dashboard screen's
/// initState). Registrations and Subscriptions activity aren't separately
/// itemized here - there's no unified activity-log endpoint, only the
/// per-resource lists your API already exposes.
class AdminRecentActivitySection extends StatelessWidget {
  const AdminRecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.paymentsStatus == LoadStatus.error) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text(
                provider.errorMessage ?? "Couldn't load recent payments.",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        final recent = provider.payments.take(5).toList();

        if (recent.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "No recent payments.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        return Column(
          children: recent.map((p) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: const Icon(Icons.payments_outlined, color: AppColors.primary, size: 16),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\u20b9${(p.amountPaise / 100).toStringAsFixed(0)} - ${p.status}",
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        Text(
                          _formatDate(p.createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
