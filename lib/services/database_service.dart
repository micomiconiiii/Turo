import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/mentor_verification_model.dart';

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

  /// Retrieves mentor verification document (PII layer).
  Future<MentorVerificationModel?> getMentorVerification(String userId) async {
    final doc = await _db
        .collection(_mentorVerificationsCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return MentorVerificationModel.fromFirestore(doc);
  }

  /// Creates or updates mentor verification data (PII layer).
  Future<void> upsertMentorVerification(MentorVerificationModel model) async {
    await _db
        .collection(_mentorVerificationsCollection)
        .doc(model.userId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  /// Approves mentor verification:
  /// 1. Update mentor_verifications/{uid}.status = 'approved'
  /// 2. Update users/{uid}: ensure roles includes 'mentor', set is_verified=true
  Future<void> approveMentorVerification(String userId) async {
    final userRef = _db.collection(_usersCollection).doc(userId);
    final verificationRef = _db
        .collection(_mentorVerificationsCollection)
        .doc(userId);

    await _db.runTransaction((txn) async {
      final verificationSnap = await txn.get(verificationRef);
      if (!verificationSnap.exists) {
        throw StateError('Verification document not found for uid=$userId');
      }

      // Update verification status
      txn.update(verificationRef, {
        'status': 'approved',
        'updated_at': FieldValue.serverTimestamp(),
      });

      final userSnap = await txn.get(userRef);
      if (!userSnap.exists) {
        throw StateError('User document missing for uid=$userId');
      }
      final data = userSnap.data() as Map<String, dynamic>;
      final roles = List<String>.from(data['roles'] ?? []);
      if (!roles.contains('mentor')) roles.add('mentor');

      txn.update(userRef, {
        'roles': roles,
        'is_verified': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }
}
