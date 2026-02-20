import 'package:go_router/go_router.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/panchangam/panchangam_screen.dart';
import '../features/eclipse/eclipse_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/premium/premium_shell_screen.dart';
import '../shared/widgets/main_scaffold.dart';

/// App-wide navigation config using go_router.
///
/// Route structure:
///   /           → Calendar (tab 0)
///   /eclipse    → Eclipse  (tab 1)
///   /premium    → Premium  (tab 2)
///   /settings   → Settings (tab 3)
///   /panchangam/:date → Day detail (full-screen, no bottom nav)
class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/eclipse',
                builder: (context, state) => const EclipseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/premium',
                builder: (context, state) => const PremiumShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Day detail — full screen, no bottom nav
      GoRoute(
        path: '/panchangam/:date',
        builder: (context, state) {
          final String dateStr = state.pathParameters['date']!;
          final DateTime date = DateTime.parse(dateStr);
          return PanchangamScreen(date: date);
        },
      ),
    ],
  );
}
