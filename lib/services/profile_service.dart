import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/presentation/mentor_registration_screen/credentials_achievements_screen.dart';

class ProfileService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> saveUserProfile(
    UserModel user,
    UserDetailModel userDetail, {
    XFile? selfieFile,
    String? idType,
    String? idFileName,
    String? institutionalEmail,
    Uint8List? idFileBytes,
    List<Credential>? credentials,
    List<Achievement>? achievements,
  }) async {
    // Ensure the client is authenticated before attempting Storage uploads.
    final firebaseAuth = FirebaseAuth.instance;
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated. Please sign in before submitting the profile.');
    }

    // Warn if passed userId differs from signed-in user. This can cause Storage rules to deny access.
    if (user.userId.isNotEmpty && currentUser.uid != user.userId) {
      print('Warning: signed-in UID (${currentUser.uid}) does not match user.userId (${user.userId}). Storage rules may block uploads.');
    }

    try {
      // Prepare base64 payloads so the Cloud Function (with admin privileges)
      // can perform Storage uploads. This avoids client-side Storage writes.
      String? selfieBase64;
      String? selfieFileName;
      if (selfieFile != null) {
        final bytes = await selfieFile.readAsBytes();
        selfieBase64 = base64Encode(bytes);
        selfieFileName = '${user.userId}_selfie.jpg';
      }

      String? idBase64;
      if (idFileBytes != null && idFileName != null) {
        idBase64 = base64Encode(idFileBytes);
      }

      List<Map<String, dynamic>> credentialsData = [];
      if (credentials != null) {
        for (var cred in credentials) {
          String? certBase64;
          if (cred.certificateBytes != null) {
            certBase64 = base64Encode(cred.certificateBytes!);
          }
          credentialsData.add({
            'title': cred.title,
            'year': cred.year,
            'certificateFileName': cred.certificateFileName,
            'certificateBase64': certBase64,
          });
        }
      }

      List<Map<String, dynamic>> achievementsData = [];
      if (achievements != null) {
        for (var ach in achievements) {
          String? certBase64;
          if (ach.certificateBytes != null) {
            certBase64 = base64Encode(ach.certificateBytes!);
          }
          achievementsData.add({
            'title': ach.title,
            'year': ach.year,
            'certificateFileName': ach.certificateFileName,
            'certificateBase64': certBase64,
          });
        }
      }

      final callable = _functions.httpsCallable('saveUserProfile');

      // Prepare a JSON-serializable payload for the callable.
      // Cloud Functions httpsCallable requires parameters to be JSON-encodable
      // (no Timestamp, DateTime, or other non-primitive types). Convert
      // any Timestamp instances to millisecondsSinceEpoch (int) recursively.
      dynamic _serializeValue(dynamic value) {
        if (value == null) return null;
        // Firestore Timestamp -> convert to milliseconds since epoch
        if (value is Timestamp) {
          return value.toDate().millisecondsSinceEpoch;
        }
        if (value is DateTime) {
          return value.millisecondsSinceEpoch;
        }
        if (value is Map) {
          final Map<String, dynamic> out = {};
          value.forEach((k, v) {
            out[k.toString()] = _serializeValue(v);
          });
          return out;
        }
        if (value is Iterable) {
          return value.map((e) => _serializeValue(e)).toList();
        }
        // primitive (String, bool, num)
        return value;
      }

      final payload = {
        'user': _serializeValue(user.toFirestore()),
        'userDetail': _serializeValue(userDetail.toFirestore()),
        'idType': idType,
        'idFileName': idFileName,
        'idBase64': idBase64,
        'selfieFileName': selfieFileName,
        'selfieBase64': selfieBase64,
        'institutionalEmail': institutionalEmail,
        'credentials': _serializeValue(credentialsData),
        'achievements': _serializeValue(achievementsData),
      };

      await callable.call(payload);
    } on FirebaseFunctionsException catch (e) {
      print(
          "FirebaseFunctionsException while saving profile: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error in ProfileService.saveUserProfile: $e");
      rethrow;
    }
  }

  // Uploads are performed server-side. Client only sends base64 payloads.
}
