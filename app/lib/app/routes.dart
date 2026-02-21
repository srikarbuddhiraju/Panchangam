import 'package:go_router/go_router.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/today/today_screen.dart';
import '../features/family/family_screen.dart';
import '../features/panchangam/panchangam_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/main_scaffold.dart';

/// App-wide navigation config using go_router.
///
/// Tab structure:
///   /         → Calendar
///   /today    → Today (daily panchangam with day navigation)
///   /family   → Family (placeholder for v2 features)
///   /settings → Settings
///
/// Full-screen routes (no bottom nav):
///   /panchangam/:date → Day detail pushed from calendar
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
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/family',
                builder: (context, state) => const FamilyScreen(),
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
      // Day detail — full screen, no bottom nav, pushed from calendar grid
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
