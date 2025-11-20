import 'package:cloud_firestore/cloud_firestore.dart';

class MenteeProfile {
  final String id;
  final String fullName;
  final DateTime joinDate;
  final String profileImageUrl;

  // --- Fields from your Figma Design ---
  final String bio; // The "About" section
  final List<String>
      skillsToLearn; // The tags on top of the image (UI/UX, Frontend)
  final List<String>
      targetMentors; // "I'm looking for" (Software Engineer, IT Mentor)
  final String budget; // "My budget is" (PHP200/hr)
  final List<String> goals; // "Goals" (Career Development, Long-term)
  final String notes; // "Notes" section

  // --- Metadata ---
  final String currentRole; // Useful for filtering (e.g. "Student")
  final String status; // e.g. 'seeking_mentor'

  const MenteeProfile({
    required this.id,
    required this.fullName,
    required this.joinDate,
    required this.profileImageUrl,
    required this.bio,
    required this.skillsToLearn,
    required this.targetMentors,
    required this.budget,
    required this.goals,
    required this.notes,
    required this.currentRole,
    required this.status,
  });

  // --- Factory: Initial/Empty ---
  factory MenteeProfile.initial(String userId) {
    return MenteeProfile(
      id: userId,
      fullName: '',
      joinDate: DateTime.now(),
      profileImageUrl: '',
      bio: '',
      skillsToLearn: [],
      targetMentors: [],
      budget: '',
      goals: [],
      notes: '',
      currentRole: '',
      status: 'seeking_mentor',
    );
  }

  // --- Serialization: To Firestore ---
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'joinDate': Timestamp.fromDate(joinDate),
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'skillsToLearn': skillsToLearn,
      'targetMentors': targetMentors,
      'budget': budget,
      'goals': goals,
      'notes': notes,
      'currentRole': currentRole,
      'status': status,
    };
  }

  // --- Deserialization: From Firestore ---
  factory MenteeProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Document data was null");

    return MenteeProfile(
      id: snapshot.id,
      fullName: data['fullName'] ?? '',
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: data['profileImageUrl'] ?? '',
      bio: data['bio'] ?? '',
      skillsToLearn: List<String>.from(data['skillsToLearn'] ?? []),
      targetMentors: List<String>.from(data['targetMentors'] ?? []),
      budget: data['budget'] ?? '',
      goals: List<String>.from(data['goals'] ?? []),
      notes: data['notes'] ?? '',
      currentRole: data['currentRole'] ?? '',
      status: data['status'] ?? 'seeking_mentor',
    );
  }
}

  // Update factory initial and fromFirestore accordingly...
  // (I can provide the full file if you need it, but these are the key fields)