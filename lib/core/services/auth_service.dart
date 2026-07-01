import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import 'package:noor_energy/core/constants/auth_email_api_config.dart';
import 'package:noor_energy/core/constants/auth_email_continue_urls.dart';

// =============================================================================
// AUTH SERVICE - Firebase Authentication (email & password).
// Verification and password-reset emails are sent via Resend (your domain):
//   1) Standalone auth-email API (no Blaze) — preferred when configured
//   2) Firebase Cloud Functions + Resend (requires Blaze billing)
//   3) Firebase built-in emails (often spam) — last resort only
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
        try {
          await _sendVerificationEmailPreferred();
        } catch (e) {
          debugPrint('Verification email failed after sign-up: $e');
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
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD - Send reset email.
  // ---------------------------------------------------------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();

    if (await _sendPasswordResetViaAuthEmailApi(trimmed)) return;

    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendAuthPasswordResetEmail')
          .call({'email': trimmed});
      return;
    } catch (e) {
      debugPrint('Cloud Function password reset failed: $e');
    }

    debugPrint(
      'Using Firebase built-in password reset (may land in spam). '
      'Deploy server/auth-email-api or enable Blaze for Cloud Functions.',
    );
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
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    await user.updateDisplayName(name.trim());
  }

  // ---------------------------------------------------------------------------
  // EMAIL VERIFICATION - Send verification email (e.g. after signup).
  // ---------------------------------------------------------------------------
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.emailVerified) return;
    await _sendVerificationEmailPreferred();
  }

  Future<void> _sendVerificationEmailPreferred() async {
    if (await _sendVerificationViaAuthEmailApi()) return;

    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendAuthVerificationEmail')
          .call();
      return;
    } catch (e) {
      debugPrint('Cloud Function verification email failed: $e');
    }

    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      debugPrint(
        'Using Firebase built-in verification email (may land in spam). '
        'Deploy server/auth-email-api or enable Blaze for Cloud Functions.',
      );
      try {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: kEmailVerifiedContinueUrl,
            handleCodeInApp: false,
          ),
        );
      } on FirebaseAuthException catch (e) {
        throw Exception(_messageFromCode(e.code, e.message));
      }
    }
  }

  Future<bool> _sendVerificationViaAuthEmailApi() async {
    if (!AuthEmailApiConfig.isConfigured) return false;

    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final idToken = await user.getIdToken();
      final uri = Uri.parse(
        '${AuthEmailApiConfig.baseUrl}/v1/send-verification',
      );
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint(
        'Auth email API verification failed (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('Auth email API verification error: $e');
    }
    return false;
  }

  Future<bool> _sendPasswordResetViaAuthEmailApi(String email) async {
    if (!AuthEmailApiConfig.isConfigured) return false;

    try {
      final uri = Uri.parse(
        '${AuthEmailApiConfig.baseUrl}/v1/send-password-reset',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint(
        'Auth email API password reset failed (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      debugPrint('Auth email API password reset error: $e');
    }
    return false;
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
