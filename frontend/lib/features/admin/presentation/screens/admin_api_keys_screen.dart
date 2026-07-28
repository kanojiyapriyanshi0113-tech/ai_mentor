import "package:flutter/material.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";

/// No API key management endpoint exists yet - shown as an honest
/// empty state instead of fabricating keys.
class AdminApiKeysScreen extends StatelessWidget {
  const AdminApiKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("API Keys"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("API key generation isn't connected to a backend endpoint yet.")),
            ),
          ),
        ],
      ),
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
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.xl)),
                  child: const Icon(Icons.vpn_key_outlined, size: 32, color: AppColors.primary),
                ),
                SizedBox(height: AppSpacing.xl),
                const Text("No API keys yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                SizedBox(height: AppSpacing.sm),
                const Text(
                  "Generated keys for third-party integrations will appear here once connected.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

