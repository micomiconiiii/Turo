import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for Firebase.app()
import '../models/mentor_verification_model.dart';
import '../models/user_model.dart';
import '../models/user_detail_model.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AdminService {
  // CORRECT INITIALIZATION: Connects to the 'turo' database specifically
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'turo',
  );

  /// STREAM: Listens to pending verifications in real-time.
  /// Includes DEBUG LOGS to help trace why data might be missing.
  Stream<List<MentorVerificationModel>> streamPendingVerifications() {
    print("🔍 STREAM STARTING: Listening to mentor_verifications...");

    return _db
        .collection('mentor_verifications')
        .where('status', isEqualTo: 'pending')
        // Note: orderBy is temporarily removed to ensure legacy data (missing timestamps) appears.
        // .orderBy('submitted_at', descending: false)
        .snapshots()
        .map((snapshot) {
          print(
            "📦 SNAPSHOT RECEIVED: Found ${snapshot.docs.length} documents.",
          );

          if (snapshot.docs.isEmpty) {
            print(
              "⚠️ WARNING: Collection is empty or Rules are blocking read.",
            );
          }

          return snapshot.docs
              .map((doc) {
                print("📄 Processing Doc ID: ${doc.id}");
                // print("   Data: ${doc.data()}"); // Uncomment to see raw data in console

                try {
                  final model = MentorVerificationModel.fromFirestore(doc);
                  print("   ✅ Parsed Successfully. Status: ${model.status}");
                  return model;
                } catch (e) {
                  print("   ❌ PARSING ERROR for ${doc.id}: $e");
                  // Return a "Broken" model so we can see it in the UI instead of hiding it
                  return MentorVerificationModel(
                    uid: doc.id,
                    selfieUrl: '',
                    idUrl: '',
                    status: 'error',
                    submittedAt: DateTime.now(),
                    institutionName: 'Parsing Failed: $e',
                  );
                }
              })
              .whereType<MentorVerificationModel>() // Filter out any nulls
              .toList();
        })
        .handleError((error) {
          // Critical for debugging Permission Denied errors
          print("🛑 STREAM ERROR: $error");
          throw error;
        });
  }

  /// HELPER: Fetches the display name for a specific UID.
  /// Strategies:
  /// 1. Try 'users' collection (Public Profile)
  /// 2. If missing, try 'user_details' collection (Private Data)
  Future<String> getMentorName(String uid) async {
    try {
      // Strategy 1: Public Profile
      var doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('display_name') &&
            data['display_name'].toString().isNotEmpty) {
          return data['display_name'];
        }
      }

      // Strategy 2: Private Details (Fallback)
      doc = await _db.collection('user_details').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('full_name')) {
          return data['full_name'];
        }
      }

      return 'Unknown User ($uid)';
    } catch (e) {
      print("Error fetching name for $uid: $e");
      return 'Error loading name';
    }
  }

  /// ACTION: Approve Mentor
  /// 1. Updates verification status to 'approved'
  /// 2. Updates public user profile 'is_verified' to true
  /// 3. Logs the action in 'activities'
  Future<void> approveMentor(String uid) async {
    WriteBatch batch = _db.batch();

    // 1. Mark verification approved
    DocumentReference verifRef = _db
        .collection('mentor_verifications')
        .doc(uid);
    batch.update(verifRef, {'status': 'approved'});

    // 2. Publicly verify user (Unlocks their profile in Swipe Deck)
    DocumentReference userRef = _db.collection('users').doc(uid);
    batch.update(userRef, {'is_verified': true});

    // 3. Log activity
    DocumentReference activityRef = _db.collection('activities').doc();
    batch.set(activityRef, {
      'event_type': 'mentor_approved',
      'description': 'Mentor $uid approved by admin.',
      'related_user_id': uid,
      'created_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    print("✅ Mentor $uid Approved.");
  }

  /// ACTION: Reject Mentor
  /// Updates status to 'rejected', saves the reason, AND logs the activity.
  Future<void> rejectMentor(String uid, String reason) async {
    WriteBatch batch = _db.batch();

    // 1. Update Verification Status & Notes
    DocumentReference verifRef = _db
        .collection('mentor_verifications')
        .doc(uid);
    batch.update(verifRef, {
      'status': 'rejected',
      'admin_notes': reason, // Stores the rejection reason
    });

    // 2. Log Activity (This was missing!)
    DocumentReference activityRef = _db.collection('activities').doc();
    batch.set(activityRef, {
      'event_type': 'mentor_rejected',
      'description': 'Mentor application rejected. Reason: $reason',
      'related_user_id': uid,
      'created_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    print("❌ Mentor $uid Rejected. Reason: $reason");
  }

  /// SEEDER: Generates a Test Mentor Application
  /// Creates data in all 3 layers (users, user_details, mentor_verifications)
  /// so you can test the approval flow without a mobile device.
  Future<void> seedPendingMentor() async {
    // Generate a unique ID based on time
    String fakeUid = 'test_mentor_${DateTime.now().millisecondsSinceEpoch}';

    WriteBatch batch = _db.batch();

    // 1. LAYER 1: Public Profile (users)
    DocumentReference userRef = _db.collection('users').doc(fakeUid);
    batch.set(userRef, {
      'user_id': fakeUid,
      'display_name': 'Test Mentor ${DateTime.now().second}',
      'bio': 'I am a generated test mentor for the admin panel.',
      'profile_picture_url': 'https://i.pravatar.cc/300', // Random avatar
      'roles': ['mentor'],
      'is_verified': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // 2. LAYER 2: Private Details (user_details)
    DocumentReference detailsRef = _db.collection('user_details').doc(fakeUid);
    batch.set(detailsRef, {
      'user_id': fakeUid,
      'full_name': 'Juan Dela Cruz (Test Seed)',
      'email': 'mentor.${DateTime.now().millisecondsSinceEpoch}@turo.ph',
      'birthdate': Timestamp.fromDate(DateTime(1990, 1, 1)),
      'address': '123 Test St., Manila',
      'created_at': FieldValue.serverTimestamp(),
    });

    // 3. LAYER 3: Verification Queue (mentor_verifications)
    // We include the 'credentials' list to match your FINAL DESIGN (PDF)
    DocumentReference verifRef = _db
        .collection('mentor_verifications')
        .doc(fakeUid);
    batch.set(verifRef, {
      'uid': fakeUid,
      'selfie_url': 'https://placehold.co/400x600/png?text=Selfie',
      'id_url': 'https://placehold.co/600x400/png?text=Gov+ID',
      // Using the NEW schema (List of Maps)
      'credentials': [
        {
          'file_name': 'Diploma.pdf',
          'file_url': 'https://example.com/diploma.pdf',
          'status': 'pending',
        },
        {
          'file_name': 'License.jpg',
          'file_url': 'https://example.com/license.jpg',
          'status': 'pending',
        },
      ],
      'status': 'pending',
      'submitted_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    print("✅ Seeded Pending Mentor: $fakeUid");
  }

  /// STREAM: Listen to ALL users (Public Profiles) for the main table
  Stream<List<UserModel>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return UserModel.fromFirestore(doc.data(), doc.id);
            } catch (e) {
              print("Error parsing user ${doc.id}: $e");
              return UserModel(
                userId: doc.id,
                displayName: 'Error User',
                bio: '',
                roles: ['unknown'],
              );
            }
          }).toList();
        });
  }

  /// FETCH: Get Private Details (Email, Real Name, Active Status)
  /// We fetch this ON DEMAND (Future) instead of Streaming to save reads.
  Future<UserDetailModel?> getUserDetails(String uid) async {
    try {
      final doc = await _db.collection('user_details').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserDetailModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching details for $uid: $e");
      return null;
    }
  }

  /// ACTION: Ban or Unban a User (Via Cloud Function)
  Future<void> toggleUserStatus(String uid, bool currentStatus) async {
    // Logic: If active (true), we want to ban (shouldBan = true).
    final bool shouldBan = currentStatus;

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'toggleUserBan',
      );

      await callable.call(<String, dynamic>{
        'uid': uid,
        'shouldBan': shouldBan,
      });

      print("✅ User $uid status updated via Cloud Function.");
    } catch (e) {
      print("❌ Failed to toggle ban status: $e");
      throw e; // Rethrow so UI can handle it
    }
  }
}
