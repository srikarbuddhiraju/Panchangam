import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_strings.dart';

/// Bottom navigation shell shared by the 4 main tabs.
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  // Tab index 0 = Calendar: full width (grid fills screen naturally).
  // Tabs 1–3 (Today/Pro/Settings): constrain on wide screens.
  static const double _maxWidth = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool isCalendar = navigationShell.currentIndex == 0;
    final Widget body = (!isCalendar && width > _maxWidth)
        ? Center(child: SizedBox(width: _maxWidth, child: navigationShell))
        : navigationShell;

    return Scaffold(
      body: body,
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
            icon: const Icon(Icons.today_outlined),
            activeIcon: const Icon(Icons.today),
            label: S.today,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star_outline_rounded),
            activeIcon: const Icon(Icons.star_rounded),
            label: S.pro,
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
