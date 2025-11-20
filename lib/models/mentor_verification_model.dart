import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing sensitive mentor verification data stored in
/// the `mentor_verifications` collection.
///
/// This collection is part of the secure layer and must only contain
/// PII required for identity & institutional verification. Public
/// display/profile fields belong in the `users` document (nested
/// mentor_profile map if needed).
class MentorVerificationModel {
  final String userId;
  final String idType; // e.g., 'national_id', 'passport'
  final String? idFileUrl; // Storage URL of uploaded ID image/file
  final String? selfieUrl; // Storage URL of selfie confirmation
  final String? institutionalEmail; // Optional verified institutional email
  final String status; // 'pending', 'approved', 'rejected'
  final Timestamp? updatedAt;

  MentorVerificationModel({
    required this.userId,
    required this.idType,
    this.idFileUrl,
    this.selfieUrl,
    this.institutionalEmail,
    this.status = 'pending',
    this.updatedAt,
  });

  factory MentorVerificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError(
        'Mentor verification document missing for uid=${doc.id}',
      );
    }
    return MentorVerificationModel(
      userId: doc.id,
      idType: data['id_type'] ?? '',
      idFileUrl: data['id_file_url'],
      selfieUrl: data['selfie_url'],
      institutionalEmail: data['institutional_email'],
      status: data['status'] ?? 'pending',
      updatedAt: data['updated_at'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_type': idType,
      if (idFileUrl != null) 'id_file_url': idFileUrl,
      if (selfieUrl != null) 'selfie_url': selfieUrl,
      if (institutionalEmail != null) 'institutional_email': institutionalEmail,
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
