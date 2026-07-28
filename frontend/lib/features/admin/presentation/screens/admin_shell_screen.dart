import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../widgets/admin_bottom_nav_bar.dart";

class AdminShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShellScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

