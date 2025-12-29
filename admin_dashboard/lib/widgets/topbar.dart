import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Tawfir Energy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (user != null) ...[
            Icon(
              Icons.person,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              user.email ?? 'Admin',
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.errorColor),
              onPressed: () => _logout(context),
              tooltip: 'Déconnexion',
            ),
          ],
        ],
      ),
    );
  }
}

