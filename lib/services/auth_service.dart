import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

/// Service class for managing Firebase Authentication operations.
///
/// This is the only file that should call FirebaseAuth.instance.
/// Handles user signup, signin, signout, and integrates with DatabaseService
/// to persist user data in Firestore using the new schema:
/// - users collection (public hub)
/// - user_details collection (private data)
class AuthService {
  // Private instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Private instance of DatabaseService
  final DatabaseService _databaseService = DatabaseService();

  /// Signs up a new user with email and password.
  ///
  /// Creates a Firebase Auth user and initializes their Firestore documents
  /// using the new schema (users + user_details collections).
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  /// [fullName] - The user's full name captured at signup
  /// [role] - The user's role: 'mentor' or 'mentee'
  ///
  /// Returns the Firebase [User] object if successful, null otherwise.
  Future<User?> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    try {
      // Create the auth user
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the new User object and uid
      final User? user = userCredential.user;
      if (user == null) return null;

      final String uid = user.uid;

      // NOTE: We do NOT call user.sendEmailVerification() here
      // Instead, we use CustomFirebaseOtpService for OTP-based verification
      // The OTP will be sent from the UI after successful signup

      // Create initial user documents in Firestore using the new schema
      await _databaseService.createInitialUser(uid, email, role);

      // Return the User object
      return user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      // TODO: Replace with proper logger in production
      // ignore: avoid_print
      print('Error during sign up: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      // Handle any other exceptions
      // TODO: Replace with proper logger in production
      // ignore: avoid_print
      print('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  /// Signs in an existing user with email and password.
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  ///
  /// Returns the Firebase [User] object if successful, null otherwise.
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      // Sign in with email and password
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Get the User object
      final User? user = userCredential.user;

      // Optional: Update last_login field
      if (user != null) {
        final DocumentSnapshot userDoc = await _databaseService.getUser(
          user.uid,
        );
        if (userDoc.exists) {
          await userDoc.reference.update({'last_login': Timestamp.now()});
        }
      }

      // Return the User object
      return user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      // TODO: Replace with proper logger in production
      // ignore: avoid_print
      print('Error during sign in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      // Handle any other exceptions
      // TODO: Replace with proper logger in production
      // ignore: avoid_print
      print('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  /// Signs out the current user.
  ///
  /// Throws [FirebaseAuthException] if sign out fails.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Gets the current authenticated user.
  ///
  /// Returns the current [User] if signed in, null otherwise.
  User? get currentUser => _auth.currentUser;

  /// Gets the authentication state changes stream.
  ///
  /// This stream emits the current user when the authentication state changes.
  /// Use this in StreamBuilder to reactively respond to auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
