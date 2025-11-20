import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/models/user_detail_model.dart';

/// Service class for managing database operations with Firestore.
///
/// This service implements the new 3-Layer Schema:
/// - Layer 1: users (public hub with display info and nested profiles)
/// - Layer 2: user_details (private data like email, birthdate, address)
/// - Layer 3: mentor_verifications (verification documents for mentors)
///
/// Uses batched writes to ensure atomicity when writing multiple documents.
class DatabaseService {
  // Private instance of Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'turo',
  );

  // Collection name constants for the new 3-Layer Schema
  final String _usersCollection = "users";
  final String _userDetailsCollection = "user_details";
  // ignore: unused_field
  final String _mentorVerificationsCollection = "mentor_verifications";

  /// Creates initial user documents during signup.
  ///
  /// This method atomically creates both the public user document and
  /// the private user_details document using a batched write.
  ///
  /// [uid] - The unique identifier for the user (Firebase Auth UID)
  /// [email] - The user's email address
  /// [role] - The user's role ("mentee" or "mentor")
  ///
  /// Throws [FirebaseException] if the batch write fails.
  Future<void> createInitialUser(String uid, String email, String role) async {
    final WriteBatch batch = _db.batch();

    final userDoc = _db.collection('users').doc(uid);
    final Map<String, dynamic> userData = {
      'display_name': email.split('@')[0],
      'roles': [role],
      'is_verified': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
    batch.set(userDoc, userData);

    final userDetailDoc = _db.collection('user_details').doc(uid);
    final Map<String, dynamic> userDetailData = {
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
    };
    batch.set(userDetailDoc, userDetailData);

    await batch.commit();
  }

  /// Updates user data after mentee onboarding completion.
  ///
  /// This method atomically updates both the public user document (with display
  /// info and nested mentee_profile) and the private user_details document
  /// (with birthdate and address) using a batched write.
  ///
  /// [uid] - The unique identifier for the user
  /// [user] - The UserModel containing display info and nested mentee profile
  /// [userDetail] - The UserDetailModel containing private data
  ///
  /// Throws [FirebaseException] if the batch write fails.
  Future<void> updateMenteeOnboardingData(
    String uid,
    UserModel user,
    UserDetailModel userDetail,
  ) async {
    // Create a batched write for atomicity
    final WriteBatch batch = _db.batch();

    // Update the public users document
    batch.update(_db.collection(_usersCollection).doc(uid), user.toFirestore());

    // Update the private user_details document
    batch.update(
      _db.collection(_userDetailsCollection).doc(uid),
      userDetail.toFirestore(),
    );

    // Commit the batch (all or nothing)
    await batch.commit();
  }

  /// Retrieves a user document from the users collection.
  ///
  /// Returns the DocumentSnapshot containing public user data.
  ///
  /// [userId] - The unique identifier for the user
  Future<DocumentSnapshot> getUser(String userId) async {
    return _db.collection(_usersCollection).doc(userId).get();
  }

  /// Retrieves a user_details document.
  ///
  /// Returns the DocumentSnapshot containing private user data.
  ///
  /// [userId] - The unique identifier for the user
  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return _db.collection(_userDetailsCollection).doc(userId).get();
  }
}
