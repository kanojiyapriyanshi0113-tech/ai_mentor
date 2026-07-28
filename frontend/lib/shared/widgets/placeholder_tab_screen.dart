import "package:flutter/material.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

/// Generic "coming soon" body used for bottom-nav tabs that aren't
/// wired to a real screen yet (Teacher Content/Students/Calendar,
/// Admin Management/Analytics).
class PlaceholderTabScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const PlaceholderTabScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(icon, size: 32, color: AppColors.primary),
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

