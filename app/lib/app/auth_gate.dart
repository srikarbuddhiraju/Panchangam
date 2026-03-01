import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/settings/settings_provider.dart';
import '../services/auth_service.dart';
import 'splash_overlay.dart';

/// Sits above the whole app and decides what to show based on auth state.
///
/// - Loading  → blank screen (auth state not yet known)
/// - Signed out → [LoginScreen]
/// - Signed in → [child] (the main app), with isPremium auto-set from email
class AuthGate extends ConsumerWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => const _Blank(),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();

        // Auto-set isPremium based on the signed-in email.
        // This runs synchronously during build — safe because SettingsNotifier
        // only writes to Hive when the value actually changes.
        final isPro = AuthService.isProEmail(user.email);
        final current = ref.read(settingsProvider).isPremium;
        if (current != isPro) {
          // Schedule after this build frame to avoid mutating provider mid-build.
          Future.microtask(
            () => ref.read(settingsProvider.notifier).setIsPremium(isPro),
          );
        }

        return SplashOverlay(child: child);
      },
    );
  }
}

class _Blank extends StatelessWidget {
  const _Blank();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
