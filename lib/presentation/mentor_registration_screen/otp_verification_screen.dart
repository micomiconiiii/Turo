import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';
import '../../core/app_export.dart';
import '../../services/custom_firebase_otp_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';
import './id_upload_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final UserModel user;
  final UserDetailModel userDetail;
  final String? institutionalEmail;
  final bool isInstitutional; // <--- 1. Add this flag

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.user,
    required this.userDetail,
    this.institutionalEmail,
    this.isInstitutional = false, // Default to false (Normal flow)
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onVerifyPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isVerifying = true);

    try {
      final otp = _pinController.text.trim();

      // Verify OTP and sign in with custom token
      final result = await CustomFirebaseOtpService.verifyEmailOTP(
        widget.email,
        otp,
      );

      if (!mounted) return;

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Check if this is institutional verification flow
        if (widget.isInstitutional) {
          // CASE A: Institutional Verification (mentor flow continuation)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IdUploadScreen(
                user: widget.user,
                userDetail: widget.userDetail,
                institutionalEmail: widget.email,
              ),
            ),
          );
        } else {
          // CASE B: Primary Registration Flow - Route based on role
          // Get current user UID
          final uid = _authService.currentUser?.uid;
          if (uid == null) {
            throw Exception('User not authenticated');
          }

          // Fetch user document to check role
          final userDoc = await _databaseService.getUser(uid);
          if (!userDoc.exists) {
            throw Exception('User document not found');
          }

          final userData = userDoc.data() as Map<String, dynamic>;
          final roles = List<String>.from(userData['roles'] ?? []);

          if (!mounted) return;

          // Route based on role
          if (roles.contains('mentor')) {
            // Navigate to mentor registration
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.mentorRegistrationScreen,
              arguments: {'user': widget.user, 'userDetail': widget.userDetail},
            );
          } else if (roles.contains('mentee')) {
            // Navigate to mentee onboarding
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.menteeOnboardingPage,
            );
          } else {
            throw Exception('Invalid user role');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid or expired OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      // ... (The rest of your UI code remains exactly the same) ...
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Text(
                  'Email Verification',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Enter the OTP sent to ${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.body12RegularFustat.copyWith(
                    color: appTheme.gray_800,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                Pinput(
                  controller: _pinController,
                  length: 6,
                  autofocus: true,
                  validator: (s) {
                    return s?.length == 6 ? null : 'Pin is incorrect';
                  },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) => _onVerifyPressed(),
                ),
                SizedBox(height: 32.h),
                _isVerifying
                    ? const CircularProgressIndicator()
                    : CustomButton(text: 'Verify', onPressed: _onVerifyPressed),
                TextButton(
                  onPressed: () async {
                    final success =
                        await CustomFirebaseOtpService.resendEmailOTP(
                          widget.email,
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'OTP resent successfully'
                              : 'Failed to resend OTP',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(color: appTheme.blue_gray_700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
