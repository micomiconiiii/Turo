import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turo/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';

class MenteeMatchingDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'turo',
  );

  /// Fetches ALL mentees from the users collection.
  Future<List<UserModel>> getSuggestedMentees(String mentorId) async {
    // ... (existing implementation)
    try {
      print("DEBUG: Fetching all users for diagnostics...");

      final snapshot = await _db.collection('users').get();

      if (snapshot.docs.isEmpty) {
        print("DEBUG: No users found in database.");
        return [];
      }

      List<UserModel> validProfiles = [];
      print("DEBUG: analyzing ${snapshot.docs.length} documents...");
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final docId = doc.id;

        UserModel? user;
        try {
          user = UserModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print("❌ Doc $docId: FAILED PARSING. Error: $e");
          continue;
        }

        if (user.userId == mentorId) {
          print("⚠️ Doc $docId: REJECTED. Reason: It is YOU (The logged-in user).");
          continue;
        }

        if (user.menteeProfile == null) {
          print(
              "⚠️ Doc $docId: REJECTED. Reason: 'mentee_profile' is MISSING or NULL.");
          print("   -> Actual keys in DB: ${data.keys.toList()}");
          continue;
        }

        print("✅ Doc $docId: ACCEPTED. Adding to list.");
        validProfiles.add(user);
      }
      print("Returning ${validProfiles.length} profiles.");
      return validProfiles;
    } catch (e) {
      print('ERROR: $e');
      return [];
    }
  }

  /// Records a swipe action (Like/Pass) to Firestore.
  /// This implementation is now generic and handles swipes from both mentors and mentees.
// 1. Update recordSwipe to call the check immediately after writing
 Future<bool> recordSwipe({
    required String mentorId,
    required String menteeId,
    required bool isLike,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("User not logged in.");

    // Determine ID order
    // If I am the Mentee, I am the 'swiper'. If I am the Mentor, I am the 'swiper'.
    final String swiperId = currentUser.uid == menteeId ? menteeId : mentorId;
    final String swipedId = currentUser.uid == menteeId ? mentorId : menteeId;

    try {
      final String docId = '${swiperId}_$swipedId';

      // A. Record Your Swipe
      await _db.collection('swipes').doc(docId).set({
        // Security Fields (REQUIRED by your Rules)
        'mentorId': mentorId,
        'menteeId': menteeId,
        
        // Metadata
        'from': swiperId,
        'to': swipedId,
        'action': isLike ? 'like' : 'pass',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // B. INSTANT CHECK: If you liked them, did they like you back?
      if (isLike) {
        // CRITICAL: We await the result and RETURN it.
        return await _checkForMutualMatch(
          currentUserId: swiperId,
          targetUserId: swipedId,
          mentorId: mentorId,
          menteeId: menteeId,
        );
      }
      
      return false; // You passed, or it wasn't a like.
    } catch (e) {
      print("Error recording swipe: $e");
      return false;
    }
  }

  // 2. Check for Mutual Match
  Future<bool> _checkForMutualMatch({
    required String currentUserId,
    required String targetUserId,
    required String mentorId,
    required String menteeId,
  }) async {
    try {
      // Logic: Look for the "Reverse Swipe" document (Them -> You)
      final String reverseDocId = '${targetUserId}_$currentUserId';
      
      // NOTE: This read works because we updated the Firestore Rules to allow 
      // reading if your ID is part of the filename.
      final DocumentSnapshot reverseSwipe = 
          await _db.collection('swipes').doc(reverseDocId).get();

      if (reverseSwipe.exists) {
        final data = reverseSwipe.data() as Map<String, dynamic>?;
        
        // Did they 'like' you?
        if (data?['action'] == 'like') {
          print("🎉 IT'S A MATCH! Creating match document...");

          // Create the Match Document (Unlocks Chat)
          await _db.collection('matches').add({
            'users': [mentorId, menteeId],
            'mentorId': mentorId,
            'menteeId': menteeId,
            'timestamp': FieldValue.serverTimestamp(),
            'lastMessage': 'You matched! Say hi.',
            'lastMessageTime': FieldValue.serverTimestamp(),
            'readBy': [currentUserId], // Mark as read for the creator
          });
          
          return true; // MATCH FOUND!
        }
      }
      return false; // No match yet
    } catch (e) {
      print("Error checking match: $e");
      return false;
    }
  }
   Future<List<UserModel>> getSuggestedMentors(String menteeId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('mentor_profile', isNotEqualTo: null)
          .get();

      if (snapshot.docs.isEmpty) {
        print("DEBUG: No users with mentor_profile found.");
        return [];
      }

      List<UserModel> mentors = [];
      for (var doc in snapshot.docs) {
        if (doc.id == menteeId) {
          continue;
        }

        try {
          mentors.add(UserModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>));
        } catch (e) {
          print("Error parsing mentor ${doc.id}: $e");
        }
      }
      print("Returning ${mentors.length} suggested mentors.");
      return mentors;
    } catch (e) {
      print('Error getting suggested mentors: $e');
      return [];
    }
  }
}