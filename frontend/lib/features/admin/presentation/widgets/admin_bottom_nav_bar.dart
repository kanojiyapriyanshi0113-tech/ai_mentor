import "package:flutter/material.dart";

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: "Dashboard"),
    _NavItemData(icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings, label: "Management"),
    _NavItemData(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: "Analytics"),
    _NavItemData(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: "Notifications"),
    _NavItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[500],
      showUnselectedLabels: true,
      items: _items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
