import 'package:firebase_auth/firebase_auth.dart';
import 'package:noor_energy/core/services/firestore_service.dart';
import 'package:noor_energy/core/services/user_state_service.dart';
import 'package:noor_energy/features/auth/data/models/user_model.dart';

/// Helper functions for authentication and role management
class AuthHelper {
  /// Initialize user role after login
  /// Call this after successful Firebase Auth login
  static Future<void> initializeUserRole(String userId) async {
    try {
      final firestoreService = FirestoreService();
      
      // Get user document from Firestore
      final userDoc = await firestoreService.getUserDocument(userId);
      
      if (userDoc != null) {
        // Create UserModel from Firestore data
        final userModel = UserModel.fromMap(userId, userDoc);
        
        // Set user in global state service
        UserStateService.instance.setUser(userModel);
      } else {
        // User document doesn't exist - create with default 'client' role
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await firestoreService.createUserDocument(
            userId: userId,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            role: 'client', // Default role
          );
          
          // Set default client role
          final defaultUser = UserModel(
            id: userId,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            role: UserRole.client,
          );
          UserStateService.instance.setUser(defaultUser);
        }
      }
    } catch (e) {
      // On error, set default client role
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final defaultUser = UserModel(
          id: userId,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          role: UserRole.client,
        );
        UserStateService.instance.setUser(defaultUser);
      }
    }
  }

  /// Clear user state on logout
  static void clearUserState() {
    UserStateService.instance.clearUser();
  }
}

