import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'admin_v2/admin_layout.dart';
import 'admin_v2/utils/app_theme.dart';

/// Main entry point for Admin Dashboard V2
/// 
/// Run with: flutter run -d chrome -t lib/main_admin_v2.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for French locale
  try {
    await initializeDateFormatting('fr', null);
    debugPrint('✅ Admin V2: Date formatting initialized');
  } catch (e) {
    debugPrint('⚠️ Admin V2: Date formatting initialization warning: $e');
  }
  
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
    debugPrint('✅ Admin V2: Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Admin V2: Firebase initialization error: $e');
  }
  
  runApp(const AdminV2App());
}

class AdminV2App extends StatelessWidget {
  const AdminV2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAWFIR ENERGY - Admin Dashboard V2',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          primary: AppTheme.primaryColor,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      // Check if user is logged in
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // If user is logged in, show admin dashboard
          if (snapshot.hasData) {
            return const AdminLayoutV2();
          }
          
          // If not logged in, show login page
          return _LoginPage();
        },
      ),
    );
  }
}

/// Simple Login Page for Admin V2
class _LoginPage extends StatefulWidget {
  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'TAWFIR ',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'ENERGY',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Admin Dashboard V2',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
