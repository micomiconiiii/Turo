import 'package:cloud_firestore/cloud_firestore.dart';

class MentorVerificationModel {
  final String uid;
  final String selfieUrl;
  final String idUrl;
  final String status;
  final DateTime submittedAt;

  // --- PDF SCHEMA FIELDS ---
  final List<CredentialItem> credentials;

  // --- LEGACY/SCREENSHOT FIELDS (To support existing data) ---
  final String? institutionName;
  final String? jobTitle;

  // --- UI HELPER ---
  String? displayName; // Fetched separately

  MentorVerificationModel({
    required this.uid,
    required this.selfieUrl,
    required this.idUrl,
    required this.status,
    required this.submittedAt,
    this.credentials = const [],
    this.institutionName,
    this.jobTitle,
    this.displayName,
  });

  factory MentorVerificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MentorVerificationModel(
      uid: doc.id,
      // Handle missing fields gracefully with empty strings
      selfieUrl: data['selfie_url'] ?? '',
      idUrl: data['id_url'] ?? '',
      status: data['status'] ?? 'pending',

      // Safe Timestamp parsing (Fixes "invisible data" if timestamp is missing)
      submittedAt:
          (data['submitted_at'] as Timestamp?)?.toDate() ?? DateTime.now(),

      // Parse PDF Schema (Array of Maps)
      credentials:
          (data['credentials'] as List<dynamic>?)
              ?.map((e) => CredentialItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],

      // Parse Screenshot/Legacy Data
      institutionName: data['institution_name'],
      jobTitle: data['job_title'],
    );
  }
}

class CredentialItem {
  final String fileName;
  final String fileUrl;
  final String status;

  CredentialItem({
    required this.fileName,
    required this.fileUrl,
    required this.status,
  });

  factory CredentialItem.fromMap(Map<String, dynamic> data) {
    return CredentialItem(
      fileName: data['file_name'] ?? 'Document',
      fileUrl: data['file_url'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }
}
