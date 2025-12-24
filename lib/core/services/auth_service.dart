import 'package:firebase_auth/firebase_auth.dart';

/// AuthService handles all authentication operations using Firebase Auth.
/// 
/// Firebase Auth provides:
/// - Email/password authentication
/// - User session management
/// - Secure token handling
class AuthService {
  // FirebaseAuth instance - the main entry point for Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // GETTERS - Access current authentication state
  // ============================================================

  /// Returns the currently signed-in user, or null if no user is signed in.
  /// Firebase automatically persists the user session.
  User? get currentUser => _auth.currentUser;

  /// Quick check if a user is currently authenticated.
  bool get isAuthenticated => currentUser != null;

  /// Get the unique user ID (UID) - used to identify user data in Firestore.
  String? get currentUserId => currentUser?.uid;

  /// Get the user's email address.
  String? get currentUserEmail => currentUser?.email;

  /// Stream that emits whenever the auth state changes.
  /// Useful for listening to login/logout events in the UI.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============================================================
  // SIGN IN - Authenticate existing user
  // ============================================================

  /// Signs in a user with email and password.
  /// 
  /// Returns [User] on success, throws [FirebaseAuthException] on failure.
  /// 
  /// Common error codes:
  /// - 'user-not-found': No user with this email
  /// - 'wrong-password': Incorrect password
  /// - 'invalid-email': Email format is invalid
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // signInWithEmailAndPassword authenticates the user
      // and automatically saves the session
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // credential.user contains the authenticated user info
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Re-throw with the error code for handling in UI
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // SIGN UP - Create new user account
  // ============================================================

  /// Creates a new user account with email and password.
  /// 
  /// Returns [User] on success, throws [FirebaseAuthException] on failure.
  /// 
  /// Common error codes:
  /// - 'email-already-in-use': Account exists with this email
  /// - 'weak-password': Password is too weak (min 6 chars)
  /// - 'invalid-email': Email format is invalid
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      // createUserWithEmailAndPassword creates the account
      // and automatically signs in the user
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // SIGN OUT - End user session
  // ============================================================

  /// Signs out the current user.
  /// 
  /// This clears the local session and tokens.
  /// After sign out, currentUser will be null.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  /// Sends a password reset email to the specified address.
  /// 
  /// The email contains a link that allows the user to reset their password.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  /// Converts Firebase error codes to user-friendly messages.
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Une erreur est survenue: ${e.message}';
    }
  }
}
