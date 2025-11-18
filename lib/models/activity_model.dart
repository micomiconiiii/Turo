import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class for system activity log
///
/// Represents the global, chronological log of all system events
/// Used to populate the "Recent Activities" list
class ActivityModel {
  final String eventType; // e.g., 'user_registered', 'mentor_approved'
  final String description; // e.g., 'New user: john.doe@example.com'
  final String? relatedUserId; // The UID of the user involved in the activity
  final Timestamp createdAt;

  ActivityModel({
    required this.eventType,
    required this.description,
    this.relatedUserId,
    required this.createdAt,
  });

  /// Convert ActivityModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'event_type': eventType,
      'description': description,
      'related_user_id': relatedUserId,
      'created_at': createdAt,
    };
  }

  /// Create ActivityModel from Firestore document
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      eventType: data['event_type'] ?? '',
      description: data['description'] ?? '',
      relatedUserId: data['related_user_id'],
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  /// Get relative time string (e.g., "5 min ago", "2 hours ago")
  String getRelativeTime() {
    final now = DateTime.now();
    final dateTime = createdAt.toDate();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    }
  }
}
