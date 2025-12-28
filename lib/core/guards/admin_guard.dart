import 'package:flutter/material.dart';
import 'package:noor_energy/core/services/user_state_service.dart';
import 'package:noor_energy/routes/app_routes.dart';

/// Admin Guard - Ensures only admin users can access admin routes
class AdminGuard {
  /// Check if current user is admin, redirect to home if not
  static bool checkAdminAccess(BuildContext context) {
    if (!UserStateService.instance.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeScreen);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accès refusé. Seuls les administrateurs peuvent accéder à cette section.'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return false;
    }
    return true;
  }

  /// Wrapper widget that checks admin access before showing child
  static Widget guard({
    required Widget child,
  }) {
    return Builder(
      builder: (context) {
        if (!UserStateService.instance.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.homeScreen);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
    );
  }
}

