import "package:flutter/material.dart";

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