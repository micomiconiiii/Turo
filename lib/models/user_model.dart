import 'package:turo/models/mentee_profile_model.dart';

/// Model class representing the main user document in the users collection.
///
/// This is the public hub that contains display information and nested profiles
/// for mentees and mentors. Private data (email, birthdate, address) is stored
/// separately in the user_details collection.
class UserModel {
  final String userId;
  final String displayName;
  final String bio;
  final String? profilePictureUrl;
  final List<String> roles;
  final MenteeProfileModel? menteeProfile;
  final Map<String, dynamic>? mentorProfile;

  /// Creates a [UserModel] with all required fields.
  UserModel({
    required this.userId,
    required this.displayName,
    required this.bio,
    this.profilePictureUrl,
    required this.roles,
    this.menteeProfile,
    this.mentorProfile,
  });

  /// Converts this model to a Firestore-compatible map with snake_case keys.
  ///
  /// If [menteeProfile] is not null, it converts the nested profile using
  /// its own toFirestore() method and adds it to the 'mentee_profile' key.
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'roles': roles,
      if (menteeProfile != null) 'mentee_profile': menteeProfile!.toFirestore(),
      if (mentorProfile != null) 'mentor_profile': mentorProfile,
    };
  }
}
