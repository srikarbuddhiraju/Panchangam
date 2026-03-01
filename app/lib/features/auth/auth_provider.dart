import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';

/// Streams the current Firebase [User] — null when signed out.
/// Riverpod rebuilds any widget or provider that watches this whenever
/// the auth state changes (sign-in, sign-out, token refresh).
final authStateProvider = StreamProvider<User?>(
  (ref) => AuthService.instance.authStateChanges,
);
