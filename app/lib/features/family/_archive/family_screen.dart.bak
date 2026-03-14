import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_strings.dart';
import '../auth/auth_provider.dart';
import '../events/my_events_screen.dart';
import '../premium/premium_guard.dart';
import '../settings/settings_provider.dart';

/// Pro tab entry point.
///
/// Not signed in  → MyEventsScreen (shows sign-in prompt).
/// Signed in, free → thin Scaffold with the upgrade teaser from PremiumGuard.
/// Signed in, Pro  → full MyEventsScreen (owns its own Scaffold + AppBar + FAB).
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    // Not signed in — MyEventsScreen handles the sign-in prompt.
    if (user == null) return const MyEventsScreen();

    final isPremium = ref.watch(settingsProvider).isPremium;

    // Pro path: MyEventsScreen owns its full Scaffold (app bar + FAB).
    if (isPremium) return const MyEventsScreen();

    // Signed-in but free — show upgrade teaser.
    return Scaffold(
      appBar: AppBar(
        title: Text(S.isTelugu ? 'నా సందర్భాలు' : 'My Events'),
        centerTitle: true,
      ),
      body: const PremiumGuard(child: SizedBox.shrink()),
    );
  }
}
