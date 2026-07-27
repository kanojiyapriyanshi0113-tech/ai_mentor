import "package:flutter/material.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

/// Shared header for Admin/Teacher dashboards:
/// greeting + name, avatar, notification bell, search button.
class DashboardHeader extends StatelessWidget {
  final String greeting; // e.g. "Welcome Admin" / "Welcome Teacher"
  final String name;
  final String? role; // e.g. "Admin" / "Teacher" - shown under the name
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSearchTap;
  final bool hasUnreadNotifications;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.name,
    this.role,
    this.avatarUrl,
    this.onAvatarTap,
    this.onNotificationsTap,
    this.onSearchTap,
    this.hasUnreadNotifications = false,
  });

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    final parts = trimmed.split(RegExp(r"\s+"));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty) ? NetworkImage(avatarUrl!) : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? Text(
                    _initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (role != null && role!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    role!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onSearchTap,
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            ),
            if (hasUnreadNotifications)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
