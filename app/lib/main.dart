import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/theme.dart';
import 'app/routes.dart';
import 'core/city_lookup/city_lookup.dart';
import 'core/utils/hive_keys.dart';
import 'features/settings/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for now (landscape support later)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize local storage
  await Hive.initFlutter();
  await Hive.openBox(HiveKeys.settingsBox);

  // Initialize locale data for Telugu date formatting
  await initializeDateFormatting('te', null);

  // Load city database from bundled asset
  await CityLookup.initialize(rootBundle);

  runApp(
    const ProviderScope(
      child: PanchangamApp(),
    ),
  );
}

class PanchangamApp extends ConsumerWidget {
  const PanchangamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'పంచాంగం',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: AppRoutes.router,
    );
  }
}
