import 'package:go_router/go_router.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/events/event_form_screen.dart';
import '../features/events/todo_form_screen.dart';
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
///   /family   → My Events (Pro) / upgrade teaser (free)
///   /settings → Settings
///
/// Full-screen push routes (no bottom nav):
///   /panchangam/:date → Day detail
///   /events/new       → Add event (optional ?tithi=N query param pre-fills tithi)
///   /events/:id       → Edit event
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
      // Day detail — full screen, pushed from calendar grid
      GoRoute(
        path: '/panchangam/:date',
        builder: (context, state) {
          final String dateStr = state.pathParameters['date']!;
          final DateTime date = DateTime.parse(dateStr);
          return PanchangamScreen(date: date);
        },
      ),

      // Add new personal tithi event
      // Optional query param: ?tithi=N (pre-fills tithi picker, set by "Mark this tithi" FAB)
      GoRoute(
        path: '/events/new',
        builder: (context, state) {
          final tithiStr = state.uri.queryParameters['tithi'];
          final prefill = tithiStr != null ? int.tryParse(tithiStr) : null;
          return EventFormScreen(prefillTithi: prefill);
        },
      ),

      // Edit existing personal tithi event
      GoRoute(
        path: '/events/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventFormScreen(eventId: id);
        },
      ),

      // Add new To-Do
      // Optional query param: ?tithi=N (pre-fills tithi picker)
      GoRoute(
        path: '/todos/new',
        builder: (context, state) {
          final tithiStr = state.uri.queryParameters['tithi'];
          final prefill = tithiStr != null ? int.tryParse(tithiStr) : null;
          return TodoFormScreen(prefillTithi: prefill);
        },
      ),

      // Edit existing To-Do
      GoRoute(
        path: '/todos/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TodoFormScreen(todoId: id);
        },
      ),
    ],
  );
}
