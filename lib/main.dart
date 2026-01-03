import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/theme/app_theme.dart';
import 'package:noor_energy/core/services/language_service.dart';
import 'package:noor_energy/routes/app_routes.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

// Set to false to require login
const bool isDevMode = true;

/// Main entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize language service
  await LanguageService.instance.initialize();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBIJ17OtVeS218IBjnmf1UoWsxsu3YY0-k",
        authDomain: "tawfir-energy-prod-98053.firebaseapp.com",
        projectId: "tawfir-energy-prod-98053",
        storageBucket: "tawfir-energy-prod-98053.firebasestorage.app",
        messagingSenderId: "751649516744",
        appId: "1:751649516744:web:a43278ec8ae222cba449fd",
      ),
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('⚠️ Firebase features will not work. Make sure Firebase configuration files are set up.');
    debugPrint('⚠️ For Android: Add google-services.json to android/app/');
    debugPrint('⚠️ For iOS: Add GoogleService-Info.plist to ios/Runner/');
    debugPrint('⚠️ For Web: Firebase config is in lib/main.dart');
    // App will still run but Firebase features won't work
  }
  
  // Verify Firebase is initialized
  if (Firebase.apps.isEmpty) {
    debugPrint('⚠️ WARNING: No Firebase apps initialized. Firebase features will not work.');
  }
  
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
    // Initialize language service
    LanguageService.instance.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    // Listen to language changes
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    // Rebuild the app when language changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current locale - this will be updated when language changes
    final currentLocale = LanguageService.instance.currentLocale;
    final isRTL = currentLocale.languageCode == 'ar';
    
    return MaterialApp(
      title: 'Tawfir Energy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: currentLocale,
      // Enable RTL layout for Arabic
      builder: (context, child) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: isDevMode ? AppRoutes.homeScreen : AppRoutes.loginScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

