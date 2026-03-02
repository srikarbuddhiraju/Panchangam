import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';
import '../../services/auth_service.dart';

/// Shown to users who are not signed in.
/// A single "Sign in with Google" button — no email/password, no clutter.
///
/// [onSuccess] is called after a successful sign-in. Use this to close a
/// bottom sheet — when omitted the widget just stays mounted and the
/// surrounding tree will rebuild via authStateProvider.
class LoginScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  const LoginScreen({super.key, this.onSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (user != null) {
        // Success — close sheet or let the tree rebuild.
        widget.onSuccess?.call();
        return;
      }
      // user == null means the user cancelled the Google picker.
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      // Surface the real error so we can diagnose (HARD RULE #1).
      // Once the error type is confirmed, replace with a user-friendly message.
      debugPrint('Sign-in exception: ${e.runtimeType}: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Sign-in error: ${e.runtimeType}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App icon placeholder — gold star
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icon.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  S.isTelugu ? 'పంచాంగం' : 'Panchangam',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.kGold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your personal events and reminders.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 48),

                // Google Sign-In button
                _loading
                    ? const CircularProgressIndicator()
                    : OutlinedButton.icon(
                        onPressed: _signIn,
                        icon: Image.asset(
                          'assets/icon/google_logo.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.login,
                            size: 20,
                          ),
                        ),
                        label: const Text('Sign in with Google'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                        ),
                      ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: cs.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
