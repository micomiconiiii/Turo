import '../../../models/user_model.dart';

class MenteeProfile {
  final String id;
  final String fullName;
  final DateTime? joinDate;
  final String profileImageUrl;

  final String bio;
  final List<String> skillsToLearn;
  final List<String> targetMentors;
  final String budget;
  final List<String> goals;
  final String notes;

  final String currentRole;
  final String status;
  final bool isVerified;
  final String duration;
  final List<String> interests;

  const MenteeProfile({
    required this.id,
    required this.fullName,
    this.joinDate,
    required this.profileImageUrl,
    required this.bio,
    required this.skillsToLearn,
    required this.targetMentors,
    required this.budget,
    required this.goals,
    required this.notes,
    required this.currentRole,
    required this.status,
    required this.isVerified,
    required this.duration,
    required this.interests,
  });

  factory MenteeProfile.fromUserModel(UserModel user) {
    return MenteeProfile(
      id: user.userId,
      fullName: user.displayName,
      joinDate: null, // No source for this in user model, can be fetched from user_details if needed
      profileImageUrl: (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty)
          ? user.profilePictureUrl!
          : 'assets/images/default_avatar.jpg',
      bio: user.bio ?? '',
      isVerified: user.isVerified ?? false,
      duration: user.menteeProfile?.duration ?? '',
      interests: user.menteeProfile?.interests ?? [],
      skillsToLearn: user.menteeProfile?.interests ?? [],
      targetMentors: [], // No source in new models
      budget: _formatBudget(user.menteeProfile?.budget),
      goals: user.menteeProfile?.goals ?? [],
      notes: '', // No source in new models
      currentRole: '', // No source in new models
      status: 'seeking_mentor', // Assumed from the context of matching
     
    );
  }

  static String _formatBudget(Map<String, double>? budget) {
    if (budget == null || budget.isEmpty) {
      return 'Not specified';
    }
    final min = budget['min'] ?? 0;
    final max = budget['max'] ?? 0;
    if (min == 0 && max == 0) return 'Not specified';
    if (min == max) return 'PHP ${max.toStringAsFixed(0)}/hr';
    return 'PHP ${min.toStringAsFixed(0)}-${max.toStringAsFixed(0)}/hr';
  }
}
