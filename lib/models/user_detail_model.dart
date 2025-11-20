import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a user's private details stored in the user_details collection.
///
/// This model captures sensitive user information such as email, birthdate, and address.
/// This data is stored separately from public profile data for security and privacy.
class UserDetailModel {
  final String userId;
  final String? email;
  final String fullName;
  final DateTime birthdate;
  final String? address;
  final DateTime createdAt;

  /// Creates a [UserDetailModel] with all required fields.
  UserDetailModel({
    required this.userId,
    this.email,
    required this.fullName, 
    required this.birthdate,
    this.address,
    required this.createdAt,
  });

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'birthdate': Timestamp.fromDate(birthdate),
      'address': address,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a [UserDetailModel] from a Firestore document map.
  ///
  /// Throws [TypeError] if required fields are missing or have incorrect types.
  factory UserDetailModel.fromFirestore(Map<String, dynamic> data) {
    return UserDetailModel(
      userId: data['user_id'] as String,
      email: data['email'] as String?,
      fullName: data['full_name'] as String,
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      address: data['address'] as String?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}

