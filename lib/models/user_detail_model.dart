import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailModel {
  final String userId;
  final String email;
  final String fullName;
  final Timestamp birthdate;
  final String address;
  final Timestamp createdAt;

  // NEW: Support for Banning/Suspension
  final bool isActive;

  UserDetailModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.birthdate,
    required this.address,
    required this.createdAt,
    this.isActive = true, // Default to active
  });

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'birthdate': birthdate,
      'address': address,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }

  factory UserDetailModel.fromFirestore(Map<String, dynamic> data) {
    return UserDetailModel(
      userId: data['user_id'] as String? ?? '',
      email: data['email'] as String? ?? '',
      fullName: data['full_name'] as String? ?? '',
      birthdate: data['birthdate'] as Timestamp? ?? Timestamp.now(),
      address: data['address'] as String? ?? '',
      createdAt: data['created_at'] as Timestamp? ?? Timestamp.now(),
      // Handle missing field for older users (default to true)
      isActive: data['is_active'] as bool? ?? true,
    );
  }
}
