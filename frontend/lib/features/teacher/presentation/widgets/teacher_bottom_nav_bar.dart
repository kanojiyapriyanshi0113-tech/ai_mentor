import "package:flutter/material.dart";

class TeacherBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TeacherBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: "Dashboard"),
    _NavItemData(icon: Icons.folder_outlined, activeIcon: Icons.folder, label: "Content"),
    _NavItemData(icon: Icons.groups_outlined, activeIcon: Icons.groups, label: "Students"),
    _NavItemData(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: "Calendar"),
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
