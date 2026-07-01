import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:noor_energy/core/constants/auth_email_continue_urls.dart';

// =============================================================================
// AUTH SERVICE - Firebase Authentication (email & password).
// Verification and password-reset emails are sent via Cloud Functions + Resend
// (your domain) when configured, to reduce spam; otherwise Firebase built-in.
// =============================================================================

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current signed-in user, or null if not logged in.
  User? get currentUser => _auth.currentUser;

  /// Display name set at sign up (or null). Use in app bar / profile.
  String? get currentUserDisplayName => _auth.currentUser?.displayName;

  /// Stream that emits when auth state changes (login, logout).
  /// Use in main.dart to switch between LoginPage and HomePage.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // SIGN UP - Create new account (email, password, and optional display name).
  // ---------------------------------------------------------------------------
  /// Creates a new user with email and password. If [displayName] is provided,
  /// it is stored in Firebase Auth and available as currentUser.displayName.
  Future<User?> signUp(String email, String password, {String? displayName}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user != null && displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }
      if (user != null && !user.emailVerified) {
        // Try to send verification email; don't fail sign-up if it fails
        try {
          await _sendVerificationEmailPreferred();
        } catch (e) {
          // Email failed (rate limit, network, etc.) - user can request again later
          // ignore: avoid_print
          print('Verification email failed after sign-up: $e');
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN IN - Log in existing user.
  // ---------------------------------------------------------------------------
  /// Signs in with email and password.
  /// Throws [Exception] with a user-friendly message on FirebaseAuthException.
  Future<User?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN OUT - End session.
  // ---------------------------------------------------------------------------
  /// Signs out the current user. After this, authStateChanges will emit null.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD - Send reset email.
  // ---------------------------------------------------------------------------
  /// Sends a password reset email to the given address. User clicks link in email to set new password.
  /// Prefers Cloud Function (Resend/your domain) to avoid spam; falls back to Firebase built-in.
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendAuthPasswordResetEmail')
          .call({'email': trimmed});
      return;
    } catch (_) {
      // Fallback: use Firebase built-in (may go to spam)
    }
    try {
      await _auth.sendPasswordResetEmail(
        email: trimmed,
        actionCodeSettings: ActionCodeSettings(
          url: kPasswordResetContinueUrl,
          handleCodeInApp: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE - Update display name.
  // ---------------------------------------------------------------------------
  /// Updates the current user's display name (shown in app bar, profile).
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    await user.updateDisplayName(name.trim());
  }

  // ---------------------------------------------------------------------------
  // EMAIL VERIFICATION - Send verification email (e.g. after signup).
  // ---------------------------------------------------------------------------
  /// Sends a verification email to the current user. Call after signUp.
  /// Prefers Cloud Function (Resend/your domain) to avoid spam; falls back to Firebase built-in.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.emailVerified) return;
    await _sendVerificationEmailPreferred();
  }

  /// Tries custom Resend email first; on failure uses Firebase built-in.
  /// Throws if both fail (caller should catch if needed).
  Future<void> _sendVerificationEmailPreferred() async {
    // Try Cloud Function (Resend) first
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendAuthVerificationEmail')
          .call();
      return; // Success
    } catch (e) {
      // ignore: avoid_print
      print('Cloud Function verification email failed: $e');
    }

    // Fallback: Firebase built-in (may go to spam)
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: kEmailVerifiedContinueUrl,
            // false: true was collapsing continueUrl to the bare firebaseapp domain (SPA/admin).
            handleCodeInApp: false,
          ),
        );
      } on FirebaseAuthException catch (e) {
        throw Exception(_messageFromCode(e.code, e.message));
      }
    }
  }

  /// Whether the current user's email is verified.
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Current user email (for profile display).
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Reload user data from Firebase (call when app resumes to check email verification).
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR HANDLING - Map Firebase codes to readable messages.
  // ---------------------------------------------------------------------------
  String _messageFromCode(String code, String? fallback) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return fallback ?? 'Something went wrong. Try again.';
    }
  }
}
