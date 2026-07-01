import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/navigation/app_navigator_keys.dart';
import 'package:noor_energy/core/services/auth_service.dart';
import 'package:noor_energy/features/auth/presentation/pages/password_reset_oob_page.dart';

/// Handles Firebase Auth action links and custom URLs that return users to the app
/// after email verification or password reset in the browser.
class AuthDeepLinkService {
  AuthDeepLinkService._();
  static final AuthDeepLinkService instance = AuthDeepLinkService._();

  StreamSubscription<Uri>? _subscription;
  bool _started = false;

  /// Start after [MaterialApp] is mounted (e.g. first [WidgetsBinding.addPostFrameCallback]).
  Future<void> start() async {
    if (kIsWeb || _started) return;
    _started = true;

    try {
      final initial = await AppLinks().getInitialLink();
      if (initial != null) {
        await handleUri(initial);
      }
      _subscription = AppLinks().uriLinkStream.listen(
        handleUri,
        onError: (Object e) => debugPrint('AuthDeepLinkService stream error: $e'),
      );
    } catch (e, st) {
      debugPrint('AuthDeepLinkService.start failed: $e\n$st');
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  Future<void> handleUri(Uri uri) async {
    if (kIsWeb) return;

    // `com.tawfir.energy://auth?t=…` from hosting pages; `com.tawfir.energy://email_verified` from Firebase/OS
    if (uri.scheme == 'com.tawfir.energy' &&
        (uri.host == 'auth' || uri.host == 'email_verified')) {
      await _handleCustomAuthScheme(uri);
      return;
    }

    if (uri.scheme == 'https' &&
        uri.host == 'solar-app-f698e.firebaseapp.com' &&
        uri.path.contains('/__/auth')) {
      await _handleFirebaseAuthHandlerLink(uri);
    }
  }

  Future<void> _handleCustomAuthScheme(Uri uri) async {
    final t = uri.queryParameters['t'];
    final shouldReload =
        uri.host == 'email_verified' ||
        (uri.host == 'auth' &&
            (t == 'email_verified' || t == 'password_reset_done'));
    if (!shouldReload) return;
    try {
      await AuthService.instance.reloadUser();
    } catch (e) {
      debugPrint('AuthDeepLinkService reloadUser: $e');
    }
  }

  Future<void> _handleFirebaseAuthHandlerLink(Uri uri) async {
    final mode = uri.queryParameters['mode'];
    final code = uri.queryParameters['oobCode'];
    if (code == null || code.isEmpty) return;

    try {
      if (mode == 'verifyEmail') {
        await FirebaseAuth.instance.applyActionCode(code);
        await AuthService.instance.reloadUser();
        return;
      }
      if (mode == 'resetPassword') {
        await FirebaseAuth.instance.verifyPasswordResetCode(code);
        final nav = rootNavigatorKey.currentState;
        if (nav == null) return;
        final ctx = nav.context;
        if (!ctx.mounted) return;
        await nav.push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => PasswordResetOobPage(actionCode: code),
          ),
        );
        return;
      }
    } catch (e, st) {
      debugPrint('AuthDeepLinkService action link failed (mode=$mode): $e\n$st');
    }
  }
}
