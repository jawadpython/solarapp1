import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/login_page.dart';
import 'dashboard/main_dashboard.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // Production Firebase configuration
        apiKey: "AIzaSyBIJ17OtVeS218IBjnmf1UoWsxsu3YY0-k",
        authDomain: "tawfir-energy-prod-98053.firebaseapp.com",
        projectId: "tawfir-energy-prod-98053",
        storageBucket: "tawfir-energy-prod-98053.firebasestorage.app",
        messagingSenderId: "751649516744",
        appId: "1:751649516744:web:a43278ec8ae222cba449fd",
      ),
    );
    debugPrint('✅ Admin Dashboard: Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Admin Dashboard: Firebase initialization error: $e');
  }
  
  runApp(const AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tawfir Energy Admin Dashboard',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return const MainDashboard();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

