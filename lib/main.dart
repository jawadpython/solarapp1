import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noor_energy/core/theme/app_theme.dart';
import 'package:noor_energy/core/services/auth_service.dart';
import 'package:noor_energy/core/services/auth_deep_link_service.dart';
import 'package:noor_energy/core/services/language_service.dart';
import 'package:noor_energy/core/services/theme_service.dart';
import 'package:noor_energy/core/utils/auth_helper.dart';
import 'package:noor_energy/core/widgets/offline_overlay.dart';
import 'package:noor_energy/core/widgets/splash_screen.dart';
import 'package:noor_energy/features/auth/presentation/pages/login_page.dart';
import 'package:noor_energy/core/navigation/app_navigator_keys.dart';
import 'package:noor_energy/features/home/presentation/pages/home_screen.dart';
import 'package:noor_energy/routes/app_routes.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

/// Set to true to always show Login page on app start (for testing).
/// Set to false so users stay logged in across app restarts.
const bool kForceLoginScreenOnStart = false;

/// Main entry point of the application.
void main() async {
  // Preserve native splash until Flutter is ready
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Initialize language and theme
  await LanguageService.instance.initialize();
  await ThemeService.instance.initialize();

  // Initialize Firebase with platform-specific configuration
  try {
    if (kIsWeb) {
      // Web: Use explicit configuration
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAP5DyZ9uuM3QxbYeBlwuV6vJSXBrIX60w",
          authDomain: "solar-app-f698e.firebaseapp.com",
          projectId: "solar-app-f698e",
          storageBucket: "solar-app-f698e.firebasestorage.app",
          messagingSenderId: "744790277180",
          appId: "1:744790277180:web:0c03d9f13f78fa83695739",
        ),
      );
      debugPrint('✅ Firebase initialized successfully (Web)');
    } else {
      // iOS/Android: Auto-detect from GoogleService-Info.plist (iOS) or google-services.json (Android)
      // Firebase will automatically read the configuration files
      await Firebase.initializeApp();
      
      // Log platform info
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        debugPrint('✅ Firebase initialized successfully (iOS - using GoogleService-Info.plist)');
      } else {
        debugPrint('✅ Firebase initialized successfully (Android - using google-services.json)');
      }
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    debugPrint('⚠️ Firebase features will not work. Make sure Firebase configuration files are set up.');
    debugPrint('⚠️ For Android: Add google-services.json to android/app/');
    debugPrint('⚠️ For iOS: Add GoogleService-Info.plist to ios/Runner/');
    debugPrint('⚠️ For Web: Firebase config is in lib/main.dart');
    // App will still run but Firebase features won't work
  }
  
  // Verify Firebase is initialized
  if (Firebase.apps.isEmpty) {
    debugPrint('⚠️ WARNING: No Firebase apps initialized. Firebase features will not work.');
  } else {
    debugPrint('✅ Firebase apps initialized: ${Firebase.apps.length}');
    for (var app in Firebase.apps) {
      debugPrint('  - ${app.name}: ${app.options.projectId}');
    }
  }

  // Optional: force Login on every app start (for testing only).
  if (kForceLoginScreenOnStart && Firebase.apps.isNotEmpty) {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('✅ Auth: signed out on start (testing)');
    } catch (e) {
      debugPrint('⚠️ Auth signOut on start: $e');
    }
  }
  // When kForceLoginScreenOnStart is false, Firebase Auth keeps the user logged in across app restarts.

  runApp(const NoorEnergyApp());
}

class NoorEnergyApp extends StatefulWidget {
  const NoorEnergyApp({super.key});

  @override
  State<NoorEnergyApp> createState() => _NoorEnergyAppState();
}

class _NoorEnergyAppState extends State<NoorEnergyApp> {
  @override
  void initState() {
    super.initState();
    LanguageService.instance.initialize().then((_) {
      if (mounted) setState(() {});
    });
    LanguageService.instance.addListener(_onLanguageChanged);
    ThemeService.instance.addListener(_onThemeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthDeepLinkService.instance.start();
    });
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    ThemeService.instance.removeListener(_onThemeChanged);
    AuthDeepLinkService.instance.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Get current locale - this will be updated when language changes
    final currentLocale = LanguageService.instance.currentLocale;
    final isRTL = currentLocale.languageCode == 'ar';
    
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Tawfir Energy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeService.instance.themeMode,
      locale: currentLocale,
      // Enable RTL layout for Arabic + offline overlay (block when no internet)
      builder: (context, child) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: OfflineOverlay(child: child!),
        );
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Auth gate: show LoginPage or HomePage based on authStateChanges()
      home: const _AuthGate(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

// =============================================================================
// AUTH GATE - Shows splash screen while checking auth state, then navigates
// to Home (logged in) or Login (not logged in) with a smooth transition.
// =============================================================================
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _isInitialized = false;
  bool _minSplashTimeElapsed = false;
  User? _user;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
          if (!_isInitialized) _isInitialized = true;
        });
        if (user != null) {
          AuthHelper.initializeUserRole(user.uid);
        } else {
          AuthHelper.clearUserState();
        }
      }
    });
    _startMinSplashTimer();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _startMinSplashTimer() {
    // Show splash for at least 1.5 seconds for a smooth experience
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _minSplashTimeElapsed = true);
      }
    });
  }

  bool get _shouldShowSplash => !_isInitialized || !_minSplashTimeElapsed;

  @override
  Widget build(BuildContext context) {
    // Show splash while initializing or minimum time not elapsed
    if (_shouldShowSplash) {
      return const SplashScreen();
    }

    // After initialization, show appropriate screen with fade transition
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _user != null ? const HomeScreen() : const LoginPage(),
    );
  }
}

