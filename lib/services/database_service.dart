import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turo_app/models/user_profile_model.dart';
import 'package:turo_app/models/mentee_profile_model.dart';

/// Service class for managing database operations with Firestore.
///
/// Provides methods to create, read, update, and delete user and mentee profiles.
/// Uses batched writes to ensure atomicity when writing multiple documents.
class DatabaseService {
  // Private instance of Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'turo',
  );

  // Collection name constants
  static const String _userProfilesCollection = 'user_profiles';
  static const String _menteeProfilesCollection = 'mentee_profiles';

  /// Creates mentee onboarding data in Firestore using a batched write.
  ///
  /// This method atomically writes both the user profile and mentee profile
  /// to their respective collections. If either write fails, both are rolled back.
  ///
  /// Automatically adds `created_at` and `updated_at` server timestamps to both documents.
  ///
  /// [userId] - The unique identifier for the user/mentee
  /// [profile] - The user's personal profile information
  /// [menteeProfile] - The mentee's learning preferences and goals
  ///
  /// Throws [FirebaseException] if the batch write fails.
  Future<void> createMenteeOnboardingData({
    required String userId,
    required UserProfileModel profile,
    required MenteeProfileModel menteeProfile,
  }) async {
    // Create a batched write for atomicity
    final WriteBatch batch = _db.batch();

    // Convert models to Firestore maps and add timestamps
    final userProfileData = profile.toFirestore();
    userProfileData['created_at'] = FieldValue.serverTimestamp();
    userProfileData['updated_at'] = FieldValue.serverTimestamp();

    final menteeProfileData = menteeProfile.toFirestore();
    menteeProfileData['created_at'] = FieldValue.serverTimestamp();
    menteeProfileData['updated_at'] = FieldValue.serverTimestamp();

    // Set user profile document with timestamps
    batch.set(
      _db.collection(_userProfilesCollection).doc(userId),
      userProfileData,
    );

    // Set mentee profile document with timestamps
    batch.set(
      _db.collection(_menteeProfilesCollection).doc(userId),
      menteeProfileData,
    );

    // Commit the batch (all or nothing)
    await batch.commit();
  }

  /// Retrieves a user profile by user ID.
  ///
  /// Returns the [UserProfileModel] if found, null otherwise.
  Future<UserProfileModel?> getUserProfile(String userId) async {
    final doc = await _db.collection(_userProfilesCollection).doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfileModel.fromFirestore(doc.data()!);
  }

  /// Retrieves a mentee profile by user ID.
  ///
  /// Returns the [MenteeProfileModel] if found, null otherwise.
  Future<MenteeProfileModel?> getMenteeProfile(String userId) async {
    final doc = await _db
        .collection(_menteeProfilesCollection)
        .doc(userId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return MenteeProfileModel.fromFirestore(doc.data()!);
  }

  /// Updates an existing user profile.
  ///
  /// Uses merge: true to only update provided fields.
  /// Automatically updates the `updated_at` timestamp.
  Future<void> updateUserProfile({
    required String userId,
    required UserProfileModel profile,
  }) async {
    final userProfileData = profile.toFirestore();
    userProfileData['updated_at'] = FieldValue.serverTimestamp();

    await _db
        .collection(_userProfilesCollection)
        .doc(userId)
        .set(userProfileData, SetOptions(merge: true));
  }

  /// Updates an existing mentee profile.
  ///
  /// Uses merge: true to only update provided fields.
  /// Automatically updates the `updated_at` timestamp.
  Future<void> updateMenteeProfile({
    required String userId,
    required MenteeProfileModel menteeProfile,
  }) async {
    final menteeProfileData = menteeProfile.toFirestore();
    menteeProfileData['updated_at'] = FieldValue.serverTimestamp();

    await _db
        .collection(_menteeProfilesCollection)
        .doc(userId)
        .set(menteeProfileData, SetOptions(merge: true));
  }
}
