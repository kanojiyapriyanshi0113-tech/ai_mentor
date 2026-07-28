import "package:flutter/material.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../presentation/profile/widgets/profile_menu_tile.dart";

/// No security-settings API exists yet (2FA, session management,
/// login-history endpoints). Rendered as a real settings list with
/// disabled actions rather than a generic placeholder, so the UI
/// shape is ready to wire up once the backend lands.
class AdminSecurityScreen extends StatelessWidget {
  const AdminSecurityScreen({super.key});

  void _notConnected(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$feature isn't connected to a backend endpoint yet.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Security")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSpacing.lg), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.verified_user_outlined,
                    title: "Two-Factor Authentication",
                    subtitle: "Add an extra layer of security",
                    onTap: () => _notConnected(context, "Two-factor authentication"),
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.devices_outlined,
                    title: "Active Sessions",
                    subtitle: "Manage devices logged into this account",
                    onTap: () => _notConnected(context, "Session management"),
                  ),
                  const Divider(height: 1),
                  ProfileMenuTile(
                    icon: Icons.history_outlined,
                    title: "Login History",
                    subtitle: "Review recent sign-in activity",
                    onTap: () => _notConnected(context, "Login history"),
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

