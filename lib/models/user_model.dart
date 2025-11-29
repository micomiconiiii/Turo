import 'package:turo/models/mentee_profile_model.dart';

class UserModel {
  final String userId;
  final String displayName;
  final String bio;
  final String? profilePictureUrl;
  final List<String> roles;
  // NEW: Status directly in public profile
  final bool isActive;
  final MenteeProfileModel? menteeProfile;
  final Map<String, dynamic>? mentorProfile;

  UserModel({
    required this.userId,
    required this.displayName,
    required this.bio,
    this.profilePictureUrl,
    required this.roles,
    this.isActive = true, // Default to active
    this.menteeProfile,
    this.mentorProfile,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'roles': roles,
      'is_active': isActive, // Save it
      if (menteeProfile != null) 'mentee_profile': menteeProfile!.toFirestore(),
      if (mentorProfile != null) 'mentor_profile': mentorProfile,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserModel(
      userId: data['user_id'] ?? docId,
      displayName: data['display_name'] ?? '',
      bio: data['bio'] ?? '',
      profilePictureUrl: data['profile_picture_url'],
      roles: List<String>.from(data['roles'] ?? []),
      // Read it (default true if missing)
      isActive: data['is_active'] as bool? ?? true,
      menteeProfile: data['mentee_profile'] != null
          ? MenteeProfileModel(
              goals: List<String>.from(data['mentee_profile']['goals'] ?? []),
              interests: List<String>.from(
                data['mentee_profile']['interests'] ?? [],
              ),
              budget: Map<String, double>.from(
                data['mentee_profile']['budget'] ?? {},
              ),
              duration: data['mentee_profile']['duration'] ?? '',
            )
          : null,
      mentorProfile: data['mentor_profile'] != null
          ? Map<String, dynamic>.from(data['mentor_profile'])
          : null,
    );
  }
}
