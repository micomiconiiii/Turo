import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
import '../models/user_model.dart';
import '../models/user_detail_model.dart';
import '../models/mentor_verification_model.dart';

/// Service class for managing database operations with Firestore.
/// Implements the 3-Layer Schema: Public (users), Private (user_details), Admin (mentor_verifications).
class DatabaseService {
  // Private instance of Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'turo',
  );

  // Collection name constants
  final String _usersCollection = "users";
  final String _userDetailsCollection = "user_details";
  final String _mentorVerificationsCollection = "mentor_verifications";

  /// Creates initial user documents during signup.
  /// Shared by both Mentors and Mentees.
  Future<void> createInitialUser(String uid, String email, String role) async {
    final WriteBatch batch = _db.batch();

    final userDoc = _db.collection(_usersCollection).doc(uid);
    final Map<String, dynamic> userData = {
      'user_id': uid, // <--- ADDED: Standardize ID field
      'display_name': email.split('@')[0],
      'roles': [role],
      'is_verified': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
    batch.set(userDoc, userData);

    final userDetailDoc = _db.collection(_userDetailsCollection).doc(uid);
    final Map<String, dynamic> userDetailData = {
      'user_id': uid, // <--- ADDED: Standardize ID field
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
    };
    batch.set(userDetailDoc, userDetailData);

    await batch.commit();
  }

  /// Updates the PUBLIC user document for Mentor Onboarding (Layer 1).
  Future<void> updateUserPublic({
    required String uid,
    required String bio,
    required bool isVerified,
    required List<String> roles,
    required Map<String, dynamic> mentorProfile,
  }) async {
    try {
      final userRef = _db.collection(_usersCollection).doc(uid);
      final userSnap = await userRef.get();
      final data = userSnap.data() ?? {};

      // Merge 'mentor' into roles array if missing
      final List<String> updatedRoles = List<String>.from(data['roles'] ?? []);
      if (!updatedRoles.contains('mentor')) updatedRoles.add('mentor');

      // Merge existing and new mentorProfile data
      final Map<String, dynamic> existingMentorProfile =
          Map<String, dynamic>.from(data['mentor_profile'] ?? {});
      existingMentorProfile.addAll(mentorProfile);


      await userRef.set({
        'user_id': uid, // <--- ADDED
        'bio': bio,
        'is_verified': isVerified,
        'roles': updatedRoles,
        'mentor_profile': existingMentorProfile, // Use the merged map
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the PRIVATE user_details document for Mentor Onboarding (Layer 2).
  Future<void> updateUserDetails({
    required String uid,
    required String fullName,
    required DateTime birthdate,
    required String address,
    String? email,
  }) async {
    try {
      final userDetailRef = _db.collection(_userDetailsCollection).doc(uid);
      await userDetailRef.set({
        'user_id': uid, // <--- ADDED
        'full_name': fullName,
        'birthdate': Timestamp.fromDate(birthdate),
        'address': address,
        if (email != null) 'email': email,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a MENTOR VERIFICATION document (Layer 3 - Admin).
  /// Also handles the File Upload to Storage.
  Future<void> createMentorVerification({
    required String uid,
    required String institutionName,
    required String jobTitle,
    required XFile? idFile,
    required XFile? selfieFile,
  }) async {
    try {
      if (idFile == null || selfieFile == null) {
        throw ArgumentError('Both idFile and selfieFile must be provided');
      }

      final storage = FirebaseStorage.instance;

      // 1. Upload ID file
      final idRef = storage.ref('verifications/$uid/id_card');
      final idBytes = await idFile.readAsBytes();
      final idUpload = await idRef.putData(
        idBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final idUrl = await idUpload.ref.getDownloadURL();

      // 2. Upload Selfie file
      final selfieRef = storage.ref('verifications/$uid/selfie');
      final selfieBytes = await selfieFile.readAsBytes();
      final selfieUpload = await selfieRef.putData(
        selfieBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final selfieUrl = await selfieUpload.ref.getDownloadURL();

      // 3. Create Verification Doc
      final verificationRef = _db
          .collection(_mentorVerificationsCollection)
          .doc(uid);
      await verificationRef.set({
        'user_id': uid, // <--- ADDED
        'institution_name': institutionName,
        'job_title': jobTitle,
        'id_url': idUrl,
        'selfie_url': selfieUrl,
        'status': 'pending',
        'submitted_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ------------------- EXISTING HELPER METHODS -------------------

  Future<void> updateMenteeOnboardingData(
    String uid,
    UserModel user,
    UserDetailModel userDetail,
  ) async {
    final WriteBatch batch = _db.batch();

    // Mentee models ALREADY have user_id in toFirestore(), so this is safe.
    batch.update(_db.collection(_usersCollection).doc(uid), user.toFirestore());
    batch.update(
      _db.collection(_userDetailsCollection).doc(uid),
      userDetail.toFirestore(),
    );
    await batch.commit();
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    return _db.collection(_usersCollection).doc(userId).get();
  }

  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return _db.collection(_userDetailsCollection).doc(userId).get();
  }

  Future<MentorVerificationModel?> getMentorVerification(String userId) async {
    final doc = await _db
        .collection(_mentorVerificationsCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return MentorVerificationModel.fromFirestore(doc);
  }

  Future<void> upsertMentorVerification(MentorVerificationModel model) async {
    await _db
        .collection(_mentorVerificationsCollection)
        .doc(model.userId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  Future<void> approveMentorVerification(String userId) async {
    final userRef = _db.collection(_usersCollection).doc(userId);
    final verificationRef = _db
        .collection(_mentorVerificationsCollection)
        .doc(userId);

    await _db.runTransaction((txn) async {
      final verificationSnap = await txn.get(verificationRef);
      if (!verificationSnap.exists)
        throw StateError('Verification document not found');

      txn.update(verificationRef, {
        'status': 'approved',
        'updated_at': FieldValue.serverTimestamp(),
      });

      final userSnap = await txn.get(userRef);
      if (!userSnap.exists) throw StateError('User document missing');

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
