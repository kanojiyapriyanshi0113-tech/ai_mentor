import "package:flutter/material.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";

/// Notification category used for filtering on the Notification Screen.
enum NotificationCategory { general, academic, batch, payment, system }

extension NotificationCategoryLabel on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.general:
        return "General";
      case NotificationCategory.academic:
        return "Academic";
      case NotificationCategory.batch:
        return "Batch";
      case NotificationCategory.payment:
        return "Payments";
      case NotificationCategory.system:
        return "System";
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.general:
        return Icons.notifications_outlined;
      case NotificationCategory.academic:
        return Icons.menu_book_outlined;
      case NotificationCategory.batch:
        return Icons.layers_outlined;
      case NotificationCategory.payment:
        return Icons.payments_outlined;
      case NotificationCategory.system:
        return Icons.dns_outlined;
    }
  }
}

class NotificationItem {
  final String id;
  final NotificationCategory category;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      category: category,
      title: title,
      message: message,
      time: time,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Notification list screen, used as both the Teacher and Admin
/// notifications route. No notifications API exists yet, so this
/// renders an empty state - swap `_items` for provider data once
/// a backend endpoint is wired up.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // No backend endpoint exists for notifications yet - kept as an
  // empty list rather than fabricating fake data.
  final List<NotificationItem> _items = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Notifications")),
      body: SafeArea(
        child: _items.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 40, color: AppColors.textSecondary),
                      SizedBox(height: AppSpacing.md),
                      const Text(
                        "No notifications yet",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      const Text(
                        "You're all caught up.",
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: item.isRead ? AppColors.surface : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(item.category.icon, size: 18, color: AppColors.primary),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              SizedBox(height: AppSpacing.xs),
                              Text(item.message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

