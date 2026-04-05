import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

/// Handles Google Sign-In and Sign-Out.
///
/// Pro status is granted automatically to accounts in [_proEmails].
/// Emails are injected at build time via --dart-define=PRO_EMAILS="a@b.com,c@d.com"
/// and never stored in source. Run via build_release.sh to ensure they are set.
///
/// This list will be replaced by a Firestore subscription check in a
/// future session when billing is wired.
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  bool _initialized = false;

  // Injected at build time — never hardcoded. See build_release.sh.
  static const _rawProEmails = String.fromEnvironment('PRO_EMAILS');
  static final _proEmails = _rawProEmails.isEmpty
      ? <String>{}
      : _rawProEmails.split(',').map((e) => e.trim()).toSet();

  /// The currently signed-in Firebase user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes — emits on sign-in and sign-out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns true if [email] qualifies for Pro access.
  static bool isProEmail(String? email) =>
      email != null && _proEmails.contains(email);

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    if (kDebugMode && _proEmails.isEmpty) {
      debugPrint(
        '⚠️  PRO_EMAILS not set — no accounts will receive Pro access.\n'
        '    Build via build_release.sh to include tester emails.',
      );
    }
    await GoogleSignInPlatform.instance.init(const InitParameters());
    _initialized = true;
  }

  /// Sign in with Google. Returns the Firebase [User] on success.
  /// Returns null if the user cancels the sign-in sheet.
  Future<User?> signInWithGoogle() async {
    await _ensureInitialized();
    try {
      final result = await GoogleSignInPlatform.instance.authenticate(
        const AuthenticateParameters(),
      );
      final credential = GoogleAuthProvider.credential(
        idToken: result.authenticationTokens.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Sign out of both Firebase and Google.
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignInPlatform.instance.signOut(const SignOutParams());
    } catch (_) {}
  }
}
