import 'package:cloud_firestore/cloud_firestore.dart';

class MentorRegistrationModel {
  final String fullName;
  final String email;
  final String address;
  final DateTime birthdate;
  final String bio;
  final List<String> expertise;
  final double hourlyRate;
  // Adding these as they are in your Confirm screen inputs
  final String? institutionName;
  final String? institutionEmail;
  final String? jobTitle;

  MentorRegistrationModel({
    required this.fullName,
    required this.email,
    required this.address,
    required this.birthdate,
    required this.bio,
    required this.expertise,
    required this.hourlyRate,
    this.institutionName,
    this.institutionEmail,
    this.jobTitle,
  });

  // --- NEW METHODS FOR 3-LAYER SCHEMA ---

  /// Data that goes into the PUBLIC 'users' collection.
  /// Safe for other users to see.
  Map<String, dynamic> toPublicMap() {
    return {
      // We use full name as display name initially
      'display_name': fullName,
      'bio': bio,
      'roles': FieldValue.arrayUnion(['mentor']),
      // Mentor specific public profile data
      'mentor_profile': {
        'expertise': expertise,
        // Using snake_case as per database convention
        'rate_per_hour': hourlyRate,
      },
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Data that goes into the PRIVATE 'user_details' collection.
  /// Only for the user and admins. Contains PII.
  Map<String, dynamic> toPrivateMap() {
    return {
      // Legal full name kept private
      'full_name': fullName,
      'email': email,
      'address': address,
      'birthdate': Timestamp.fromDate(birthdate),
      // Optional institution details
      if (institutionName != null && institutionName!.isNotEmpty)
        'institution_name': institutionName,
      if (institutionEmail != null && institutionEmail!.isNotEmpty)
        'institution_email': institutionEmail,
      if (jobTitle != null && jobTitle!.isNotEmpty) 'job_title': jobTitle,
      // Ensure record exists if it wasn't created at signup
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
