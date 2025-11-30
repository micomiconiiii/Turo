import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String contractId;
  final String mentorId;
  final String menteeId;
  final String
  status; // 'proposed', 'active', 'completed', 'cancelled', 'disputed'
  final double rate;
  final String duration; // e.g., "Long-term"
  final String terms;
  final String paymentStatus; // 'pending_escrow', 'in_escrow', 'released'
  final DateTime createdAt;

  // UI Helper: We will fetch these names separately
  String? mentorName;
  String? menteeName;

  ContractModel({
    required this.contractId,
    required this.mentorId,
    required this.menteeId,
    required this.status,
    required this.rate,
    required this.duration,
    required this.terms,
    required this.paymentStatus,
    required this.createdAt,
    this.mentorName,
    this.menteeName,
  });

  factory ContractModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContractModel(
      contractId: data['contract_id'] ?? doc.id,
      mentorId: data['mentor_id'] ?? '',
      menteeId: data['mentee_id'] ?? '',
      status: data['status'] ?? 'proposed',
      // Safely parse numbers (int or double)
      rate: (data['rate'] is int)
          ? (data['rate'] as int).toDouble()
          : (data['rate'] as double? ?? 0.0),
      duration: data['duration'] ?? '',
      terms: data['terms'] ?? '',
      paymentStatus: data['payment_status'] ?? 'pending_escrow',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
