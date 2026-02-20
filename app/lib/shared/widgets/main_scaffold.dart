import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_strings.dart';

/// Bottom navigation shell shared by the 4 main tabs.
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month),
            label: S.calendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.nightlight_outlined),
            activeIcon: const Icon(Icons.nightlight),
            label: S.eclipse,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.workspace_premium_outlined),
            activeIcon: const Icon(Icons.workspace_premium),
            label: S.premium,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: S.settings,
          ),
        ],
      ),
    );
  }
}
