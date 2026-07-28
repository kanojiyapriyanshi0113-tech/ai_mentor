import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../providers/admin_provider.dart";

class _PendingActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value; // real count, or "-" when not backed by data yet
  final VoidCallback? onTap;

  const _PendingActionRow({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: value == "-" ? AppColors.surfaceMuted : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: value == "-" ? AppColors.textSecondary : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pending Actions section for the Admin dashboard.
///
/// Only "Teacher Approvals" is backed by real data (AdminProvider.teachers,
/// filtered by isApproved - loaded via provider.loadTeachers(), already
/// called from the dashboard screen's initState). Refund Requests, Coupon
/// Requests, and Banner Approval have no "pending/requested" status field
/// on their models (CouponModel/BannerModel only have isActive), so they
/// show "-" rather than a fabricated count.
class AdminPendingActionsSection extends StatelessWidget {
  const AdminPendingActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final pendingTeachers = provider.teachers.where((t) => !t.isApproved).length;

        return Column(
          children: [
            _PendingActionRow(
              icon: Icons.person_add_alt_outlined,
              label: "Teacher Approvals",
              value: "$pendingTeachers",
            ),
            const Divider(height: 1),
            const _PendingActionRow(
              icon: Icons.currency_rupee_outlined,
              label: "Refund Requests",
              value: "-",
            ),
            const Divider(height: 1),
            const _PendingActionRow(
              icon: Icons.confirmation_number_outlined,
              label: "Coupon Requests",
              value: "-",
            ),
            const Divider(height: 1),
            const _PendingActionRow(
              icon: Icons.image_outlined,
              label: "Banner Approvals",
              value: "-",
            ),
          ],
        );
      },
    );
  }
}
