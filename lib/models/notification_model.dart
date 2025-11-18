import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class for admin notifications
///
/// Represents targeted messages for specific admin users
/// Used to alert admins of critical, high-priority actions
class NotificationModel {
  final String? id; // Firestore document ID (optional)
  final String userId; // The admin recipient's ID
  final String message; // e.g., 'Contract #1234 needs review'
  final String type; // e.g., 'dispute', 'verification', 'payment'
  final String? contractId; // Optional link to the related contract
  final Timestamp createdAt;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.userId,
    required this.message,
    required this.type,
    this.contractId,
    required this.createdAt,
    required this.isRead,
  });

  /// Convert NotificationModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'message': message,
      'type': type,
      'contract_id': contractId,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      contractId: data['contract_id'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      isRead: data['is_read'] ?? false,
    );
  }

  /// Copy with method for updating fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? message,
    String? type,
    String? contractId,
    Timestamp? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      type: type ?? this.type,
      contractId: contractId ?? this.contractId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
