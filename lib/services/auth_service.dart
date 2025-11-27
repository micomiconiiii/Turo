import 'package:firebase_auth/firebase_auth.dart';

/// Service class for managing Firebase Authentication operations ONLY.
/// 
/// Data persistence (Firestore) is handled by the specific Providers 
/// (e.g., MentorRegistrationProvider) to ensure the correct data structure 
/// is written for each user role.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs up a new user with email and password.
  ///
  /// Returns the Firebase [User] object if successful, null otherwise.
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      // 1. Create the auth user
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Return the User object
      // We do NOT write to Firestore here. The Provider handles that.
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      print('Error during sign up: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  /// Signs in an existing user with email and password.
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error during sign in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Gets the current authenticated user.
  User? get currentUser => _auth.currentUser;

  /// Authentication state stream.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}