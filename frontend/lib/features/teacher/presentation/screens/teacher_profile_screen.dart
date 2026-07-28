import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";

import "../../../../core/models/user_model.dart";
import "../../../../core/network/profile_api_service.dart";
import "../../../../core/providers/user_provider.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/storage/secure_storage_service.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/widgets/coming_soon_screen.dart";
import "../../../../presentation/profile/widgets/profile_menu_tile.dart";
import "../providers/teacher_provider.dart";

/// Teacher Profile screen.
///
/// Real data: name, email, joined date (GET /profile, same endpoint
/// every logged-in user hits), plus subject/batch COUNTS from the
/// teacher dashboard model.
///
/// NOTE: Phone, Qualification, Experience, and a list of assigned
/// batches (vs. just a count) are NOT in any backend model yet - there
/// is no phone/qualification/experience field anywhere in the API, and
/// no endpoint returning a teacher's actual batch list. Add these
/// fields to the backend to show them here instead of omitting them.
class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final _profileService = ProfileApiService();
  final _secureStorage = SecureStorageService();

  bool _isLoading = true;
  bool _isSavingName = false;
  bool _isLoggingOut = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    final teacherProvider = context.read<TeacherProvider>();
    if (teacherProvider.dashboardStatus == LoadStatus.idle) {
      teacherProvider.loadDashboard();
    }
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final dashboard = context.watch<TeacherProvider>().dashboard;

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
                        const Center(
                          child: Text(
                            "Teacher",
                            style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
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

                        // Real counts from the dashboard - not phone/qualification/
                        // experience, which don't exist in any backend model yet.
                        Container(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatColumn(label: "Subjects", value: dashboard?.totalSubjects),
                              _StatColumn(label: "Batches", value: dashboard?.totalBatches),
                              _StatColumn(label: "Students", value: dashboard?.totalStudents),
                            ],
                          ),
                        ),
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
                                icon: Icons.lock_outline,
                                title: "Change Password",
                                onTap: () => context.push(AppRoutes.forgotPassword),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.notifications_outlined,
                                title: "Notification Settings",
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ComingSoonScreen(
                                      title: "Notification Settings",
                                      message:
                                          "There is no per-user notification preference storage on the backend yet.",
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.privacy_tip_outlined,
                                title: "Privacy Policy",
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ComingSoonScreen(
                                      title: "Privacy Policy",
                                      message: "No privacy policy content is wired up yet.",
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.help_outline,
                                title: "Help",
                                onTap: () => context.push(AppRoutes.help),
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

class _StatColumn extends StatelessWidget {
  final String label;
  final int? value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value?.toString() ?? "-",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

