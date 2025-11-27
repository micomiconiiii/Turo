import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/mentor_registration_model.dart';

class MentorRegistrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Submits the Mentor Application.
  /// 1. Uploads ID and Selfie to Storage.
  /// 2. Writes data to 3 separate Firestore collections atomically.
  Future<void> submitMentorApplication({
    required String uid,
    required MentorRegistrationModel profileData,
    required File idFile,
    required File selfieFile,
  }) async {
    try {
      // STEP 1: Upload Files to Firebase Storage
      // We use a clean folder structure: users/{uid}/verification_docs/
      String idUrl = await _uploadFile(uid, idFile, 'id_document');
      String selfieUrl = await _uploadFile(
        uid,
        selfieFile,
        'selfie_verification',
      );

      // STEP 2: Prepare the Atomic Batch Write
      // If one part fails, EVERYTHING fails. No broken data.
      WriteBatch batch = _db.batch();

      // Reference A: Public Layer (users)
      DocumentReference publicRef = _db.collection('users').doc(uid);
      batch.set(publicRef, profileData.toPublicMap(), SetOptions(merge: true));

      // Reference B: Private Layer (user_details)
      DocumentReference privateRef = _db.collection('user_details').doc(uid);
      batch.set(
        privateRef,
        profileData.toPrivateMap(),
        SetOptions(merge: true),
      );

      // Reference C: Admin Layer (mentor_verifications)
      // This is where we link the Storage URLs we just got.
      DocumentReference adminRef = _db
          .collection('mentor_verifications')
          .doc(uid);
      batch.set(adminRef, {
        'id_url': idUrl,
        'selfie_url': selfieUrl,
        'status': 'pending',
        'submitted_at': FieldValue.serverTimestamp(),
        // Optional: Add metadata if needed for quick admin checks
        'id_type': 'National ID', // You can pass this in the model if dynamic
      });

      // STEP 3: Commit
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  /// Helper method to upload file and get URL
  Future<String> _uploadFile(String uid, File file, String filename) async {
    try {
      // Create a reference: users/UID/verification_docs/filename.jpg
      String ext = file.path.split('.').last; // Get extension (jpg, png)
      Reference ref = _storage.ref().child(
        'users/$uid/verification_docs/$filename.$ext',
      );

      UploadTask task = ref.putFile(file);
      TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }
}
