import "package:flutter/material.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../presentation/profile/widgets/profile_menu_tile.dart";

/// No backup/export endpoint exists yet - actions surface an honest
/// "not connected" message instead of pretending to run a backup.
class AdminBackupScreen extends StatelessWidget {
  const AdminBackupScreen({super.key});

  void _notConnected(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$feature isn't connected to a backend endpoint yet.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Backup")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSpacing.lg), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Last Backup", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.xs),
                  const Text("Never", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSpacing.lg), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.backup_outlined,
                    title: "Run Backup Now",
                    subtitle: "Create a full database backup",
                    onTap: () => _notConnected(context, "Manual backup"),
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.schedule_outlined,
                    title: "Backup Schedule",
                    subtitle: "Configure automatic backups",
                    onTap: () => _notConnected(context, "Backup scheduling"),
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.download_outlined,
                    title: "Download Latest Backup",
                    onTap: () => _notConnected(context, "Backup download"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

