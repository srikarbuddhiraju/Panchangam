import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_strings.dart';
import '../events/my_events_screen.dart';
import '../premium/premium_guard.dart';
import '../settings/settings_provider.dart';

/// Family tab entry point.
///
/// Pro users → full MyEventsScreen (which provides its own Scaffold + AppBar + FAB).
/// Free users → thin Scaffold with the upgrade teaser from PremiumGuard.
///
/// This two-branch approach avoids a double-Scaffold (MyEventsScreen has its own).
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(settingsProvider).isPremium;

    // Pro path: MyEventsScreen owns its full Scaffold (app bar + FAB)
    if (isPremium) return const MyEventsScreen();

    // Free path: thin Scaffold so the upgrade teaser has a proper app bar
    return Scaffold(
      appBar: AppBar(
        title: Text(S.isTelugu ? 'నా సందర్భాలు' : 'My Events'),
        centerTitle: true,
      ),
      body: const PremiumGuard(child: SizedBox.shrink()),
    );
  }
}
