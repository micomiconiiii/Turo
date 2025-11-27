import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;            // The Firestore Document ID (Chat Room ID)
  final List<String> users;   // IDs of both users [mentorId, menteeId]
  final String lastMessage;   // For the inbox preview
  final DateTime timestamp;   // When the match happened

  MatchModel({
    required this.id,
    required this.users,
    required this.lastMessage,
    required this.timestamp,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      users: List<String>.from(data['users'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}