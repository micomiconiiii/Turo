import 'package:cloud_firestore/cloud_firestore.dart';

class Credential {
  final String title;
  final int year;
  final String? certificateUrl;

  Credential({
    required this.title,
    required this.year,
    this.certificateUrl,
  });

  factory Credential.fromMap(Map<String, dynamic> data) {
    return Credential(
      title: data['title'] ?? '',
      year: data['year'] ?? 0,
      certificateUrl: data['certificateUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      if (certificateUrl != null) 'certificateUrl': certificateUrl,
    };
  }
}

class Achievement {
  final String title;
  final int year;
  final String? certificateUrl;

  Achievement({
    required this.title,
    required this.year,
    this.certificateUrl,
  });

  factory Achievement.fromMap(Map<String, dynamic> data) {
    return Achievement(
      title: data['title'] ?? '',
      year: data['year'] ?? 0,
      certificateUrl: data['certificateUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      if (certificateUrl != null) 'certificateUrl': certificateUrl,
    };
  }
}

class MentorProfileModel {
  final String userId;
  final String idType;
  final String? idFileName;
  final String? idFileUrl;
  final String? selfieUrl;
  final List<Credential> credentials;
  final List<Achievement> achievements;
  final String? institutionalEmail; // Added field
  final String verificationStatus; // e.g., 'pending', 'approved', 'rejected'
  final Timestamp? updatedAt;

  MentorProfileModel({
    required this.userId,
    required this.idType,
    this.idFileName,
    this.idFileUrl,
    this.selfieUrl,
    required this.credentials,
    required this.achievements,
    this.institutionalEmail, // Added to constructor
    this.verificationStatus = 'pending',
    this.updatedAt,
  });

  factory MentorProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MentorProfileModel(
      userId: data['user_id'] ?? '',
      idType: data['id_type'] ?? '',
      idFileName: data['id_file_name'],
      idFileUrl: data['id_file_url'],
      selfieUrl: data['selfie_url'],
      institutionalEmail: data['institutional_email'], // [FIX] Read from Firestore
      credentials: (data['credentials'] as List<dynamic>?)
              ?.map((c) => Credential.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      achievements: (data['achievements'] as List<dynamic>?)
              ?.map((a) => Achievement.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      verificationStatus: data['verification_status'] ?? 'pending',
      updatedAt: data['updated_at'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'id_type': idType,
      if (idFileName != null) 'id_file_name': idFileName,
      if (idFileUrl != null) 'id_file_url': idFileUrl,
      if (selfieUrl != null) 'selfie_url': selfieUrl,
      if (institutionalEmail != null) 'institutional_email': institutionalEmail, // [FIX] Write to Firestore
      'credentials': credentials.map((c) => c.toMap()).toList(),
      'achievements': achievements.map((a) => a.toMap()).toList(),
      'verification_status': verificationStatus,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}