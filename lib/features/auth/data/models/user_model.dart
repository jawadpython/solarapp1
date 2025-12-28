enum UserRole {
  client,
  technician,
  admin,
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    UserRole role = UserRole.client,
    DateTime? createdAt,
  }) : role = role,
       createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == UserRole.admin;
  bool get isTechnician => role == UserRole.technician;
  bool get isClient => role == UserRole.client;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name, // 'admin', 'technician', 'client'
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    // Parse role from string, default to 'client'
    final roleString = map['role'] as String? ?? 'client';
    UserRole userRole;
    switch (roleString.toLowerCase()) {
      case 'admin':
        userRole = UserRole.admin;
        break;
      case 'technician':
        userRole = UserRole.technician;
        break;
      default:
        userRole = UserRole.client;
    }

    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      role: userRole,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

