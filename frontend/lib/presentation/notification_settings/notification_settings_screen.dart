import "package:flutter/material.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

/// Shared Notification Settings screen for Teacher/Admin Profile.
/// Toggles are local UI state only - there's no notification-
/// preferences endpoint yet, matching the placeholder pattern used
/// elsewhere (e.g. Settings screen's existing toggles).
class NotificationSettingsScreen extends StatefulWidget {
  final bool isAdmin;

  const NotificationSettingsScreen({super.key, this.isAdmin = false});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _push = true;
  bool _email = true;
  bool _batchActivity = true;
  bool _paymentAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            Text("General", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Push Notifications"),
              subtitle: const Text("Get notified on this device"),
              value: _push,
              onChanged: (v) => setState(() => _push = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Email Notifications"),
              subtitle: const Text("Receive updates by email"),
              value: _email,
              onChanged: (v) => setState(() => _email = v),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              widget.isAdmin ? "Platform" : "Teaching",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            if (widget.isAdmin)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Payment Alerts"),
                subtitle: const Text("New payments and refunds"),
                value: _paymentAlerts,
                onChanged: (v) => setState(() => _paymentAlerts = v),
              )
            else
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Batch Activity"),
                subtitle: const Text("Enrollments and student activity in your batches"),
                value: _batchActivity,
                onChanged: (v) => setState(() => _batchActivity = v),
              ),
          ],
        ),
      ),
    );
  }
}