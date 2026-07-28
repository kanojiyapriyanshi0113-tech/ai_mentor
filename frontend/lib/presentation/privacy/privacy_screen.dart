import "package:flutter/material.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

/// Shared static Privacy screen, linked from Teacher/Admin Profile.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = [
    (
      "Data we collect",
      "Name, email, and content you create (batches, subjects, lectures, PDFs, mock tests) are stored to operate your account.",
    ),
    (
      "How it's used",
      "Your data is used to run the platform's core features - authentication, content delivery, and analytics for your own dashboard.",
    ),
    (
      "Sharing",
      "We don't sell your data. Limited data may be shared with service providers strictly to operate the app (e.g. hosting, payments).",
    ),
    (
      "Your controls",
      "You can edit your profile at any time, and request account deletion by contacting support.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            for (final section in _sections) ...[
              Text(
                section.$1,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                section.$2,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}