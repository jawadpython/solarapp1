import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/theme/app_theme.dart';
import 'package:noor_energy/routes/app_routes.dart';

// Set to false to require login
const bool isDevMode = true;

/// Main entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    // App will still run but Firebase features won't work
  }
  
  runApp(const NoorEnergyApp());
}

class NoorEnergyApp extends StatelessWidget {
  const NoorEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tawfir Energy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: isDevMode ? AppRoutes.homeScreen : AppRoutes.loginScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

