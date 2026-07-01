import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import 'package:noor_energy/core/constants/auth_email_api_config.dart';
import 'package:noor_energy/core/constants/auth_email_continue_urls.dart';

// =============================================================================
// AUTH SERVICE - Verification/reset emails via Resend (auth-email API on Render).
// When the API URL is configured we do NOT fall back to Firebase built-in mail
// (those always use @firebaseapp.com and land in spam).
// =============================================================================

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Duration _apiTimeout = Duration(seconds: 90);
  static const int _apiMaxAttempts = 3;

  User? get currentUser => _auth.currentUser;
  String? get currentUserDisplayName => _auth.currentUser?.displayName;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();

    if (AuthEmailApiConfig.isConfigured) {
      await _sendPasswordResetViaAuthEmailApiOrThrow(trimmed);
      return;
    }

    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendAuthPasswordResetEmail')
          .call({'email': trimmed});
      return;
    } catch (e) {
      debugPrint('Cloud Function password reset failed: $e');
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

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    await user.updateDisplayName(name.trim());
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.emailVerified) return;
    await _sendVerificationEmailPreferred();
  }

  Future<void> _sendVerificationEmailPreferred() async {
    if (AuthEmailApiConfig.isConfigured) {
      await _sendVerificationViaAuthEmailApiOrThrow();
      return;
    }

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

  Future<void> _sendVerificationViaAuthEmailApiOrThrow() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');

    final idToken = await user.getIdToken(true);
    await _postAuthEmailApiOrThrow(
      path: '/v1/send-verification',
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> _sendPasswordResetViaAuthEmailApiOrThrow(String email) async {
    await _postAuthEmailApiOrThrow(
      path: '/v1/send-password-reset',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  /// Wakes Render free tier, then retries POST (cold starts can take 30–60s).
  Future<void> _postAuthEmailApiOrThrow({
    required String path,
    required Map<String, String> headers,
    String? body,
  }) async {
    final uri = Uri.parse('${AuthEmailApiConfig.baseUrl}$path');
    Object? lastError;

    for (var attempt = 1; attempt <= _apiMaxAttempts; attempt++) {
      try {
        if (attempt == 1) {
          await _wakeAuthEmailApi();
        }

        final response = await http
            .post(uri, headers: headers, body: body)
            .timeout(_apiTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('Auth email API OK ($path) attempt $attempt');
          return;
        }

        String message = 'HTTP ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final err = decoded['error']?.toString();
          final detail = decoded['detail']?.toString();
          if (err != null && err.isNotEmpty) {
            message = detail != null && detail.isNotEmpty ? '$err ($detail)' : err;
          }
        } catch (_) {
          if (response.body.isNotEmpty) message = response.body;
        }

        lastError = message;
        debugPrint('Auth email API failed ($path) attempt $attempt: $lastError');
      } catch (e) {
        lastError = e;
        debugPrint('Auth email API error ($path) attempt $attempt: $e');
      }

      if (attempt < _apiMaxAttempts) {
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception(
      'Could not send email via Resend. Wait one minute and try again. '
      '($lastError)',
    );
  }

  Future<void> _wakeAuthEmailApi() async {
    try {
      final healthUri = Uri.parse('${AuthEmailApiConfig.baseUrl}/health');
      await http.get(healthUri).timeout(const Duration(seconds: 60));
    } catch (e) {
      debugPrint('Auth email API wake-up ping: $e');
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  String? get currentUserEmail => _auth.currentUser?.email;

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
