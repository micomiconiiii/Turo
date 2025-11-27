import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomFirebaseOtpService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> requestEmailOTP(String email) async {
    try {
      final callable = _functions.httpsCallable('requestEmailOTP');
      final response = await callable.call<Map<String, dynamic>>({'email': email});
      print(response.data['message']);
      return response.data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      print('Error requesting email OTP: ${e.code} - ${e.message}');
      return false;
    }
  }

  static Future<bool> verifyEmailOTP(String email, String otp) async {
    try {
      final callable = _functions.httpsCallable('verifyEmailOTP');
      email = email.toLowerCase().trim();
      otp = otp.trim();

      final response = await callable.call<Map<String, dynamic>>({
        'email': email,
        'otp': otp,
      });

      if (response.data['success'] == true && response.data['token'] != null) {
        await _auth.signInWithCustomToken(response.data['token']);
        return true;
      }
      return false;
    } on FirebaseFunctionsException catch (e) {
      return false;
    }
  }
  static Future<bool> resendEmailOTP(String email) async {
    try {
      final callable = _functions.httpsCallable('requestEmailOTP');
      final response = await callable.call<Map<String, dynamic>>({'email': email});
      return response.data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      return false;
    }
  }
}