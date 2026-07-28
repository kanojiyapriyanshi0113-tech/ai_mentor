import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/widgets/retry_state.dart";
import "../providers/admin_provider.dart";

/// Admin Settings screen - lists app-wide key/value settings and lets
/// the admin edit them. Uses AdminProvider.settings (already backed by
/// real GET/PUT /admin/settings endpoints); no backend changes made.
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.settingsStatus == LoadStatus.idle) {
        provider.loadSettings();
      }
    });
  }

  Future<void> _editSetting(BuildContext context, String key, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    final newValue = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(key),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (newValue == null || newValue == currentValue) return;
    if (!context.mounted) return;
    await context.read<AdminProvider>().setSetting(key: key, value: newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Admin Settings")),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.settingsStatus == LoadStatus.loading || provider.settingsStatus == LoadStatus.idle) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.settingsStatus == LoadStatus.error) {
            return RetryState(
              message: provider.errorMessage ?? "Couldn't load settings.",
              onRetry: provider.loadSettings,
            );
          }
          if (provider.settings.isEmpty) {
            return const Center(
              child: Text("No settings configured yet.", style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(AppSpacing.lg),
            itemCount: provider.settings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final setting = provider.settings[i];
              return ListTile(
                title: Text(setting.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(setting.value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () => _editSetting(context, setting.key, setting.value),
              );
            },
          );
        },
      ),
    );
  }
}
