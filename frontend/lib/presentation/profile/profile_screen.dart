import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";

import "../../core/models/user_model.dart";
import "../../core/network/profile_api_service.dart";
import "../../core/providers/subscription_provider.dart";
import "../../core/providers/user_provider.dart";
import "../../core/router/app_routes.dart";
import "../../core/storage/secure_storage_service.dart";
import "widgets/current_exam_card.dart";
import "widgets/profile_menu_tile.dart";
import "widgets/subscription_card.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    context.read<SubscriptionProvider>().loadSummary();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final fetched = await _profileService.getProfile();
      if (!mounted) return;

      final existing = context.read<UserProvider>().currentUser;
      final merged = UserModel(
        id: fetched.id,
        name: fetched.name,
        email: fetched.email,
        premium: fetched.premium,
        trialStartDate: fetched.trialStartDate,
        trialEndDate: fetched.trialEndDate,
        selectedExamName: existing?.selectedExamName,
        joinedAt: fetched.joinedAt,
      );

      context.read<UserProvider>().setUser(merged);
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
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: "Full Name"),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return "Enter a valid name";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newName == null || newName == currentName) return;

    setState(() => _isSavingName = true);
    try {
      final updated = await _profileService.updateProfile(name: newName);
      if (!mounted) return;

      final existing = context.read<UserProvider>().currentUser;
      final merged = UserModel(
        id: updated.id,
        name: updated.name,
        email: updated.email,
        premium: updated.premium,
        trialStartDate: updated.trialStartDate,
        trialEndDate: updated.trialEndDate,
        selectedExamName: existing?.selectedExamName,
        joinedAt: updated.joinedAt,
      );
      context.read<UserProvider>().setUser(merged);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name updated successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update name. Try again.")),
      );
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
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);
    try {
      await _secureStorage.deleteToken();
      if (!mounted) return;
      context.read<UserProvider>().clear();
      context.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        automaticallyImplyLeading: false,
      ),
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
                    onRefresh: () async {
                      await _loadProfile();
                      await context.read<SubscriptionProvider>().loadSummary();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : "?",
                              style: const TextStyle(fontSize: 32, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            user?.name ?? "-",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Center(
                          child: Text(
                            user?.email ?? "-",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SubscriptionCard(
                          summary: subscriptionProvider.summary,
                          isLoading: subscriptionProvider.isLoadingSummary,
                          onUpgradeTap: () => context.push(AppRoutes.upgradePlan),
                        ),
                        const SizedBox(height: 14),
                        CurrentExamCard(
                          examName: user?.selectedExamName,
                          onChangeExam: () => context.push(AppRoutes.examSelection),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
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
                                icon: Icons.workspace_premium_outlined,
                                title: "Upgrade Plan",
                                subtitle: "View plans and unlock more features",
                                onTap: () => context.push(AppRoutes.upgradePlan),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.settings_outlined,
                                title: "Settings",
                                subtitle: "Notifications, appearance",
                                onTap: () => context.push(AppRoutes.settings),
                              ),
                              const Divider(height: 1),
                              ProfileMenuTile(
                                icon: Icons.help_outline,
                                title: "Help & Support",
                                subtitle: "FAQs, contact us",
                                onTap: () => context.push(AppRoutes.help),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ProfileMenuTile(
                            icon: Icons.logout,
                            title: "Logout",
                            iconColor: Colors.red,
                            textColor: Colors.red,
                            isLoading: _isLoggingOut,
                            trailing: const SizedBox.shrink(),
                            onTap: _logout,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}