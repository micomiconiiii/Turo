import 'package:cloud_firestore/cloud_firestore.dart';

/// Defines the structure for a mentee's profile document.
///
/// This model includes fields for personal details, professional status,
/// and mentorship-specific data, designed to be easily serialized to and
/// deserialized from Firestore documents.
class MenteeProfile {
  // --- Core Metadata ---

  /// The unique ID of the profile document, typically matching the user's UID.
  final String id;

  /// The mentee's preferred full name.
  final String fullName;

  /// Timestamp of when the profile was created.
  final DateTime joinDate;

  // --- Personal & Professional Details ---

  /// The mentee's primary mentoring goal.
  final String primaryGoal;

  /// The mentee's current job title or student status.
  final String currentRole;

  /// The industry or domain the mentee is currently in or interested in.
  final String industryOfInterest;

  // --- Mentoring Specifics ---

  /// A list of specific skills or topics the mentee is looking to learn.
  final List<String> skillsToLearn;

  /// A string describing general availability (e.g., "Evenings (Tues/Thurs)").
  final String availability;

  /// The ID of the mentor currently assigned to this mentee (can be null/empty).
  final String? mentorId;

  /// Status of the profile ('active', 'seeking_mentor', 'matched', 'on_hold').
  final String status;

  // --- Constructor ---

  const MenteeProfile({
    required this.id,
    required this.fullName,
    required this.joinDate,
    required this.primaryGoal,
    required this.currentRole,
    required this.industryOfInterest,
    required this.skillsToLearn,
    required this.availability,
    this.mentorId,
    required this.status,
  });

  // --- Factory for Creating an Empty/Initial Profile ---

  /// Returns an initial MenteeProfile instance, useful for new user sign-up.
  factory MenteeProfile.initial(String userId) {
    return MenteeProfile(
      id: userId,
      fullName: '',
      joinDate: DateTime.now(),
      primaryGoal: 'Define your main mentoring goal',
      currentRole: 'Unspecified',
      industryOfInterest: 'Not set',
      skillsToLearn: [],
      availability: 'Please update your availability',
      mentorId: null,
      status: 'seeking_mentor',
    );
  }

  // --- Serialization (to Firestore) ---

  /// Converts this [MenteeProfile] instance into a map for storage in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'joinDate': Timestamp.fromDate(joinDate),
      'primaryGoal': primaryGoal,
      'currentRole': currentRole,
      'industryOfInterest': industryOfInterest,
      'skillsToLearn': skillsToLearn,
      'availability': availability,
      'mentorId': mentorId,
      'status': status,
    };
  }

  // --- Deserialization (from Firestore) ---

  /// Creates a [MenteeProfile] instance from a Firestore document snapshot.
  factory MenteeProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception("Document data was null for ID: ${snapshot.id}");
    }

    // Safely cast Timestamp to DateTime
    final joinTimestamp = data['joinDate'] as Timestamp?;
    final joinDateTime = joinTimestamp?.toDate() ?? DateTime.now();

    return MenteeProfile(
      id: snapshot.id, // Use the document ID for the profile ID
      fullName: data['fullName'] as String? ?? '',
      joinDate: joinDateTime,
      primaryGoal: data['primaryGoal'] as String? ?? '',
      currentRole: data['currentRole'] as String? ?? '',
      industryOfInterest: data['industryOfInterest'] as String? ?? '',
      skillsToLearn: List<String>.from(data['skillsToLearn'] ?? []),
      availability: data['availability'] as String? ?? 'N/A',
      mentorId: data['mentorId'] as String?,
      status: data['status'] as String? ?? 'seeking_mentor',
    );
  }

  // --- Utility ---

  /// Creates a copy of this MenteeProfile with optional new values.
  MenteeProfile copyWith({
    String? fullName,
    String? primaryGoal,
    String? currentRole,
    String? industryOfInterest,
    List<String>? skillsToLearn,
    String? availability,
    String? mentorId,
    String? status,
  }) {
    return MenteeProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      joinDate: joinDate, // Join date is typically immutable after creation
      primaryGoal: primaryGoal ?? this.primaryGoal,
      currentRole: currentRole ?? this.currentRole,
      industryOfInterest: industryOfInterest ?? this.industryOfInterest,
      skillsToLearn: skillsToLearn ?? this.skillsToLearn,
      availability: availability ?? this.availability,
      mentorId: mentorId ?? this.mentorId,
      status: status ?? this.status,
    );
  }
}
