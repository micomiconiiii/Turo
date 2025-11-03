/// Model class representing a mentee's profile information including preferences and goals.
///
/// This model captures mentee-specific data such as interests, learning goals,
/// preferred mentoring duration, and budget range.
/// Use [toFirestore] to convert the model to a map suitable for Firestore storage.
class MenteeProfileModel {
  final String userId;
  final List<String> interests;
  final List<String> goals;
  final String selectedDuration;
  final double minBudget;
  final double maxBudget;

  /// Creates a [MenteeProfileModel] with all required fields.
  MenteeProfileModel({
    required this.userId,
    required this.interests,
    required this.goals,
    required this.selectedDuration,
    required this.minBudget,
    required this.maxBudget,
  });

  /// Converts this model to a Firestore-compatible map with snake_case keys.
  ///
  /// Lists are stored as arrays in Firestore for efficient querying.
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'interests': interests,
      'goals': goals,
      'selected_duration': selectedDuration,
      'min_budget': minBudget,
      'max_budget': maxBudget,
    };
  }

  /// Creates a [MenteeProfileModel] from a Firestore document map.
  ///
  /// Throws [TypeError] if required fields are missing or have incorrect types.
  factory MenteeProfileModel.fromFirestore(Map<String, dynamic> data) {
    return MenteeProfileModel(
      userId: data['user_id'] as String,
      interests: List<String>.from(data['interests'] as List),
      goals: List<String>.from(data['goals'] as List),
      selectedDuration: data['selected_duration'] as String,
      minBudget: (data['min_budget'] as num).toDouble(),
      maxBudget: (data['max_budget'] as num).toDouble(),
    );
  }
}
