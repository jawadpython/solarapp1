import 'package:firebase_auth/firebase_auth.dart';

// =============================================================================
// AUTH SERVICE - Firebase Authentication only (email & password).
// No custom logic, no passwords in Firestore. All auth via FirebaseAuth.
// =============================================================================

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current signed-in user, or null if not logged in.
  User? get currentUser => _auth.currentUser;

  /// Display name set at sign up (or null). Use in app bar / profile.
  String? get currentUserDisplayName => _auth.currentUser?.displayName;

  /// Stream that emits when auth state changes (login, logout).
  /// Use in main.dart to switch between LoginPage and HomePage.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // SIGN UP - Create new account (email, password, and optional display name).
  // ---------------------------------------------------------------------------
  /// Creates a new user with email and password. If [displayName] is provided,
  /// it is stored in Firebase Auth and available as currentUser.displayName.
  Future<User?> signUp(String email, String password, {String? displayName}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user != null && displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN IN - Log in existing user.
  // ---------------------------------------------------------------------------
  /// Signs in with email and password.
  /// Throws [Exception] with a user-friendly message on FirebaseAuthException.
  Future<User?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN OUT - End session.
  // ---------------------------------------------------------------------------
  /// Signs out the current user. After this, authStateChanges will emit null.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD - Send reset email.
  // ---------------------------------------------------------------------------
  /// Sends a password reset email to the given address. User clicks link in email to set new password.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE - Update display name.
  // ---------------------------------------------------------------------------
  /// Updates the current user's display name (shown in app bar, profile).
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    await user.updateDisplayName(name.trim());
  }

  // ---------------------------------------------------------------------------
  // EMAIL VERIFICATION - Send verification email (e.g. after signup).
  // ---------------------------------------------------------------------------
  /// Sends a verification email to the current user. Call after signUp.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  /// Whether the current user's email is verified.
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Current user email (for profile display).
  String? get currentUserEmail => _auth.currentUser?.email;

  // ---------------------------------------------------------------------------
  // ERROR HANDLING - Map Firebase codes to readable messages.
  // ---------------------------------------------------------------------------
  String _messageFromCode(String code, String? fallback) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return fallback ?? 'Something went wrong. Try again.';
    }
  }
}
