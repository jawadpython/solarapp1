import 'package:flutter/material.dart';
import 'package:noor_energy/core/services/auth_service.dart';
import 'package:noor_energy/features/auth/presentation/pages/login_page.dart';
import 'package:noor_energy/features/home/presentation/pages/home_screen.dart';

/// When the OS or Firebase resolves a deeplink route name such as `email_verified`,
/// [MaterialApp.onGenerateRoute] opens this screen instead of failing with "No route defined".
class EmailVerifiedRoutePage extends StatefulWidget {
  const EmailVerifiedRoutePage({super.key});

  @override
  State<EmailVerifiedRoutePage> createState() => _EmailVerifiedRoutePageState();
}

class _EmailVerifiedRoutePageState extends State<EmailVerifiedRoutePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
  }

  Future<void> _finish() async {
    try {
      await AuthService.instance.reloadUser();
    } catch (_) {}
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    final user = AuthService.instance.currentUser;
    if (!mounted) return;
    nav.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => user != null ? const HomeScreen() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
