/// Model class representing a mentee's profile as a nested map inside the users collection.
///
/// This model captures mentee-specific data such as goals, interests,
/// budget range, and preferred mentoring duration.
class MenteeProfileModel {
  final List<String> goals;
  final List<String> interests;
  final Map<String, double> budget;
  final String duration;

  /// Creates a [MenteeProfileModel] with all required fields.
  MenteeProfileModel({
    required this.goals,
    required this.interests,
    required this.budget,
    required this.duration,
  });

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'goals': goals,
      'interests': interests,
      'budget': budget,
      'duration': duration,
    };
  }

  /// Creates a [MenteeProfileModel] from a Firestore document map.
  factory MenteeProfileModel.fromFirestore(Map<String, dynamic> data) {
    return MenteeProfileModel(
      goals: List<String>.from(data['goals'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      budget: Map<String, double>.from(data['budget'] ?? {}),
      duration: data['duration'] ?? '',
    );
  }
}
