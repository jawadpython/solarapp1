import 'package:noor_energy/features/auth/data/models/user_model.dart';

/// Global service to manage current user state and role
/// Singleton pattern for app-wide access
class UserStateService {
  static UserStateService? _instance;
  static UserStateService get instance {
    _instance ??= UserStateService._();
    return _instance!;
  }

  UserStateService._();

  UserModel? _currentUser;
  UserRole? _currentRole;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Get current user role
  UserRole? get currentRole => _currentRole;

  /// Check if current user is admin
  bool get isAdmin => _currentRole == UserRole.admin;

  /// Check if current user is technician
  bool get isTechnician => _currentRole == UserRole.technician;

  /// Check if current user is client
  bool get isClient => _currentRole == UserRole.client || _currentRole == null;

  /// Set current user and role
  void setUser(UserModel? user) {
    _currentUser = user;
    _currentRole = user?.role;
  }

  /// Clear user state (on logout)
  void clearUser() {
    _currentUser = null;
    _currentRole = null;
  }

  /// Update user role
  void updateRole(UserRole role) {
    _currentRole = role;
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        phone: _currentUser!.phone,
        role: role,
        createdAt: _currentUser!.createdAt,
      );
    }
  }
}

