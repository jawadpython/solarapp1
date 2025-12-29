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
        // Add your Firebase config here
            apiKey: "AIzaSyCfSewr0e506aoWVj-ho-X-FipAEnIvpdU",
            authDomain: "tawfir-energy.firebaseapp.com",
            projectId: "tawfir-energy",
            storageBucket: "tawfir-energy.firebasestorage.app",
            messagingSenderId: "355955928136",
            appId: "1:355955928136:web:6361bad1b397464f91bc7d",
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
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

