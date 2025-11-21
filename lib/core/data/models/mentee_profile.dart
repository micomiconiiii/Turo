//For backend data model of Mentee Profile
import 'package:cloud_firestore/cloud_firestore.dart';

class MenteeProfile {
  final String id;
  final String fullName;
  final DateTime joinDate;
  final String profileImageUrl;

  final String bio;
  final List<String> skillsToLearn;
  final List<String> targetMentors;
  final String budget;
  final List<String> goals;
  final String notes;

  final String currentRole;
  final String status;

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
