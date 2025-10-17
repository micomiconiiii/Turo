import 'package:supabase_flutter/supabase_flutter.dart';

class OtpService {
  SupabaseClient get _client {
    print('🔍 Checking Supabase initialization: ${Supabase.instance.isInitialized}');
    if (!Supabase.instance.isInitialized) {
      throw Exception("Supabase is not initialized yet.");
    }
    return Supabase.instance.client;
  }

  Future<bool> sendOtp(String email) async {
    try {
      print('📧 Attempting to send OTP to: $email');
      await _client.auth.signInWithOtp(
      email: email,
      );
      print('✅ OTP sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending OTP: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String token) async {
    try {
      final res = await _client.auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: email,
      );
      return res.session != null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
}