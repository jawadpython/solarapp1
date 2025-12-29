import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/theme/app_theme.dart';
import 'package:noor_energy/core/services/language_service.dart';
import 'package:noor_energy/routes/app_routes.dart';

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
        apiKey: "AIzaSyCfSewr0e506aoWVj-ho-X-FipAEnIvpdU",
        authDomain: "tawfir-energy.firebaseapp.com",
        projectId: "tawfir-energy",
        storageBucket: "tawfir-energy.firebasestorage.app",
        messagingSenderId: "355955928136",
        appId: "1:355955928136:web:6361bad1b397464f91bc7d",
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
    // Listen to language changes
    LanguageService.instance.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tawfir Energy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: LanguageService.instance.currentLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.supportedLocales,
      initialRoute: isDevMode ? AppRoutes.homeScreen : AppRoutes.loginScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

