import 'package:noor_energy/features/auth/data/models/user_model.dart';

// TODO: Connect to Firebase Auth & Firestore
abstract class AuthRepository {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data);
}

class AuthRepositoryImpl implements AuthRepository {
  // TODO: Add FirebaseAuth and FirebaseFirestore instances

  @override
  Future<UserModel?> signIn(String email, String password) async {
    // TODO: Implement Firebase signIn
    return null;
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    // TODO: Implement Firebase signUp
    return null;
  }

  @override
  Future<void> signOut() async {
    // TODO: Implement Firebase signOut
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: Implement get current user
    return null;
  }

  @override
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    // TODO: Implement Firestore update
  }
}

