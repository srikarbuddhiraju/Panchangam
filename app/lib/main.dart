import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/splash_overlay.dart';
import 'app/theme.dart';
import 'app/routes.dart';
import 'core/city_lookup/city_lookup.dart';
import 'core/utils/hive_keys.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/events/user_event_calculator.dart';
import 'features/events/user_tithi_event.dart';
import 'features/festivals/festival_loader.dart';
import 'features/settings/settings_provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for now (landscape support later)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local storage
  await Hive.initFlutter();
  await Hive.openBox(HiveKeys.settingsBox);
  await Hive.openBox(HiveKeys.userEventsBox);

  // Initialize locale data for Telugu date formatting
  await initializeDateFormatting('te', null);

  // Load city database from bundled asset
  await CityLookup.initialize(rootBundle);

  // Load festival definitions from JSON asset
  await FestivalLoader.initialize(rootBundle);

  // Initialize notification service and reschedule active event reminders.
  await NotificationService.instance.init();
  await _rescheduleAllNotifications();

  runApp(
    const ProviderScope(
      child: PanchangamApp(),
    ),
  );
}

/// Re-schedule notifications for all active events with reminders.
///
/// Called on startup so alarms survive device reboots.
Future<void> _rescheduleAllNotifications() async {
  final settingsBox = Hive.box(HiveKeys.settingsBox);
  final lat =
      (settingsBox.get(HiveKeys.latitude, defaultValue: 17.3850) as num)
          .toDouble();
  final lng =
      (settingsBox.get(HiveKeys.longitude, defaultValue: 78.4867) as num)
          .toDouble();

  final eventsBox = Hive.box(HiveKeys.userEventsBox);
  for (final key in eventsBox.keys) {
    try {
      final raw = eventsBox.get(key) as String?;
      if (raw == null) continue;
      final event =
          UserTithiEvent.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      if (!event.isActive || event.reminderMinutes == null) continue;
      final occurrences =
          UserEventCalculator.nextOccurrences(event, DateTime.now(), lat, lng);
      await NotificationService.instance
          .scheduleForEvent(event, occurrences, lat, lng);
    } catch (_) {
      // Never let a bad stored event crash startup
    }
  }
}

class PanchangamApp extends ConsumerWidget {
  const PanchangamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final authAsync = ref.watch(authStateProvider);

    // SplashOverlay is always the root so the mantra appears immediately on
    // launch — before Firebase auth has even resolved. Its child swaps from a
    // blank scaffold (loading) to the full router (authenticated) underneath
    // the still-visible splash, then fades to reveal the ready app.
    return SplashOverlay(
      child: authAsync.when(
        loading: () => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
        error: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: const LoginScreen(),
        ),
        data: (user) {
          // Auto-set isPremium based on the signed-in email (no-op when signed out).
          if (user != null) {
            final isPro = AuthService.isProEmail(user.email);
            final current = ref.read(settingsProvider).isPremium;
            if (current != isPro) {
              Future.microtask(
                () => ref.read(settingsProvider.notifier).setIsPremium(isPro),
              );
            }
          }

          return MaterialApp.router(
            title: 'పంచాంగం',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
