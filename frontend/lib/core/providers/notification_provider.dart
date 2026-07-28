import "package:flutter/material.dart";

import "../models/notification_model.dart";

/// In-memory notification store shared by the Teacher and Admin
/// Notification Screens. No backend endpoint exists yet for
/// notifications list/read/delete, so this is seeded with sample data
/// and all mutations are local-only (mirrors the "coming soon" /
/// placeholder pattern already used on the dashboards for fields with
/// no backing API).
class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _items = [
    NotificationItem(
      id: "n1",
      category: NotificationCategory.batch,
      title: "New student enrolled",
      message: "A new student joined one of your active batches.",
      time: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationItem(
      id: "n2",
      category: NotificationCategory.academic,
      title: "Mock test submissions ready",
      message: "Results are ready for review on your latest mock test.",
      time: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationItem(
      id: "n3",
      category: NotificationCategory.payment,
      title: "Payment received",
      message: "A subscription payment was processed successfully.",
      time: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    NotificationItem(
      id: "n4",
      category: NotificationCategory.system,
      title: "Scheduled maintenance",
      message: "The platform will undergo brief maintenance tonight.",
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: "n5",
      category: NotificationCategory.general,
      title: "Welcome to AI Mentor",
      message: "Thanks for joining. Explore your dashboard to get started.",
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  List<NotificationItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  List<NotificationItem> byCategory(NotificationCategory? category) {
    if (category == null) return items;
    return _items.where((n) => n.category == category).toList();
  }

  void markRead(String id) {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1 || _items[index].isRead) return;
    _items[index] = _items[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void delete(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}