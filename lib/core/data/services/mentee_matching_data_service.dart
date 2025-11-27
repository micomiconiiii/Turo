import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turo/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/mentee_profile.dart';

class MenteeMatchingDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
  app: Firebase.app(), 
  databaseId: 'turo', // <--- This matches your Firestore Database ID
);
  /// Fetches ALL mentees from the users collection.
 Future<List<MenteeProfile>> getSuggestedMentees(String mentorId) async {
    try {
      print("DEBUG: Fetching all users for diagnostics...");
      
      // 1. Fetch everything to see what we have
      final snapshot = await _db.collection('users').get();
      
      if (snapshot.docs.isEmpty) {
        print("DEBUG: No users found in database.");
        return [];
      }

      List<MenteeProfile> validProfiles = [];

      print("DEBUG: analyzing ${snapshot.docs.length} documents...");

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final docId = doc.id;
        
        // A. Check Parsing
        UserModel? user;
        try {
          user = UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print("❌ Doc $docId: FAILED PARSING. Error: $e");
          continue;
        }

        // B. Check Filter Logic (The "Why")
        if (user.userId == mentorId) {
          print("⚠️ Doc $docId: REJECTED. Reason: It is YOU (The logged-in user).");
          continue;
        }

        if (user.menteeProfile == null) {
          print("⚠️ Doc $docId: REJECTED. Reason: 'mentee_profile' is MISSING or NULL.");
          // DEBUG TIP: Check actual keys to see if it's a spelling mismatch
          print("   -> Actual keys in DB: ${data.keys.toList()}");
          continue;
        }

        // If we get here, it's valid!
        print("✅ Doc $docId: ACCEPTED. Adding to list.");
        validProfiles.add(MenteeProfile.fromUserModel(user));
      }

      print("Returning ${validProfiles.length} profiles.");
      return validProfiles;

    } catch (e) {
      print('ERROR: $e');
      return [];
    }
  }
  /// Records a swipe action (Like/Pass) to Firestore
 Future<void> recordSwipe({
    required String mentorId,
    required String menteeId,
    required bool isLike,
  }) async {
    try {
      final String docId = '${mentorId}_$menteeId';
      
      // 1. Record the Swipe Action
      await _db.collection('swipes').doc(docId).set({
        'mentorId': mentorId,
        'menteeId': menteeId,
        'action': isLike ? 'like' : 'pass',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print("Swipe recorded: ${isLike ? 'Like' : 'Pass'} for $menteeId");

      // 2. Check for Mutual Match (Only if YOU liked THEM)
      if (isLike) {
        await _checkForMutualMatch(mentorId, menteeId);
      }

    } catch (e) {
      print("Error recording swipe: $e");
    }
  }

  // New Helper Function
  Future<void> _checkForMutualMatch(String mentorId, String menteeId) async {
    // Check if the mentee has ALREADY swiped 'like' on this mentor
    // We look for the document: menteeId_mentorId
    final reverseSwipeDoc = await _db.collection('swipes').doc("${menteeId}_$mentorId").get();

    if (reverseSwipeDoc.exists && reverseSwipeDoc.data()?['action'] == 'like') {
      print("IT'S A MATCH! Creating match record...");
      
      // 3. Create the Match Document (Unlocks Chat)
      await _db.collection('matches').add({
        'users': [mentorId, menteeId], // Critical for security rules
        'menteeId': menteeId,
        'mentorId': mentorId,
        'timestamp': FieldValue.serverTimestamp(),
        'lastMessage': 'You matched! Say hi.', // Initial message
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      
      // Optional: Trigger a local notification or UI popup here
    }
  }
}