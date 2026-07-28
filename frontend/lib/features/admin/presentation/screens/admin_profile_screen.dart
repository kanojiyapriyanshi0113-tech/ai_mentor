import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";

import "../../../../core/network/profile_api_service.dart";
import "../../../../core/providers/user_provider.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/storage/secure_storage_service.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/widgets/coming_soon_screen.dart";
import "../../../../presentation/profile/widgets/profile_menu_tile.dart";
import "admin_settings_screen.dart";

/// Admin Profile screen.
///
/// Real data: name, email, joined date (GET /profile). Role comes from
/// SecureStorageService (saved at login from the JWT claim) rather than
/// a global AuthProvider, since AuthProvider isn't registered in the
/// app's MultiProvider tree.
///
/// NOTE: "Last Login" is NOT in any backend model - there is no
/// last-login timestamp anywhere in the API. Add one to show it here.
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _profileService = ProfileApiService();
  final _secureStorage = SecureStorageService();

  bool _isLoading = true;
  bool _isSavingName = false;
  bool _isLoggingOut = false;
  String? _loadError;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _secureStorage.getRole();
    if (mounted) setState(() => _role = role);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final fetched = await _profileService.getProfile();
      if (!mounted) return;
      context.read<UserProvider>().setUser(fetched);
    } catch (e) {
      setState(() => _loadError = "Failed to load profile. Pull to retry.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edit Name"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: "Full Name"),
            validator: (value) {
              if (value == null || value.trim().length < 2) return "Enter a valid name";
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newName == null || newName == currentName) return;

    setState(() => _isSavingName = true);
    try {
      final updated = await _profileService.updateProfile(name: newName);
      if (!mounted) return;
      context.read<UserProvider>().setUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name updated successfully")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update name. Try again.")));
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text("Logout")),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);
    try {
      await _secureStorage.deleteToken();
      await _secureStorage.deleteRole();
      if (!mounted) return;
      context.read<UserProvider>().clear();
      context.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${months[dt.month - 1]} ${dt.year}";
  }

  void _openComingSoon(String title, String message) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ComingSoonScreen(title: title, message: message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Profile"), automaticallyImplyLeading: false),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_loadError!),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _loadProfile, child: const Text("Retry")),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: ListView(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : "?",
                              style: const TextStyle(fontSize: 32, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Center(
                          child: Text(user?.name ?? "-", style: Theme.of(context).textTheme.titleLarge),
                        ),
                        Center(
                          child: Text(
                            user?.email ?? "-",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            _role != null && _role!.isNotEmpty
                                ? _role![0].toUpperCase() + _role!.substring(1)
                                : "Admin",
                            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (user?.joinedAt != null) ...[
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              "Joined ${_formatDate(user!.joinedAt!)}",
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.xl),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              ProfileMenuTile(
                                icon: Icons.edit_outlined,
                                title: "Edit Profile",
                                subtitle: "Update your name",
                                isLoading: _isSavingName,
                                onTap: () => _editName(user?.name ?? ""),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.shield_outlined,
                                title: "Security",
                                onTap: () => _openComingSoon(
                                  "Security",
                                  "No password-change-while-logged-in or 2FA endpoint exists on the backend yet.",
                                ),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.settings_outlined,
                                title: "Admin Settings",
                                subtitle: "App-wide configuration",
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
                                ),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.notifications_outlined,
                                title: "Notification Settings",
                                onTap: () => _openComingSoon(
                                  "Notification Settings",
                                  "There is no per-user notification preference storage on the backend yet.",
                                ),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.vpn_key_outlined,
                                title: "API Keys",
                                onTap: () => _openComingSoon(
                                  "API Keys",
                                  "No API key management endpoint exists on the backend yet.",
                                ),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.backup_outlined,
                                title: "Backup",
                                onTap: () => _openComingSoon(
                                  "Backup",
                                  "No backup/export endpoint exists on the backend yet.",
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(AppSpacing.lg),
                          ),
                          child: ProfileMenuTile(
                            icon: Icons.logout,
                            title: "Logout",
                            iconColor: AppColors.error,
                            textColor: AppColors.error,
                            isLoading: _isLoggingOut,
                            trailing: const SizedBox.shrink(),
                            onTap: _logout,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
      ),
    );
  }
}

