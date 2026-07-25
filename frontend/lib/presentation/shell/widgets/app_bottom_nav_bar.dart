import "package:flutter/material.dart";

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: "Home"),
    _NavItemData(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: "My Courses"),
    _NavItemData(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: "AI Mentor"),
    _NavItemData(icon: Icons.edit_note_outlined, activeIcon: Icons.edit_note, label: "Practice"),
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
