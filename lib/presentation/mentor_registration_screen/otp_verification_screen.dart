// This screen is for OTP verification with flexible navigation.
// - Default behavior (no callback): Routes based on user role after verification
// - Custom callback: Executes the provided callback instead (e.g., for institutional verification)
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/app_export.dart';
import '../../services/custom_firebase_otp_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  /// Optional: Custom navigation after successful OTP verification.
  /// If provided, this will be called instead of the default role-based routing.
  final VoidCallback? onVerificationSuccess;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.onVerificationSuccess,
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isVerifying = true);

      final otp = _pinController.text.trim();

      final success = await CustomFirebaseOtpService.verifyEmailOTP(
        widget.email,
        otp,
      );
      if (!mounted) return;

      setState(() => _isVerifying = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // If custom navigation callback is provided, use it
        if (widget.onVerificationSuccess != null) {
          widget.onVerificationSuccess!();
          return;
        }

        // Otherwise, navigate based on user role (default behavior for initial signup)
        try {
          final uid = _authService.currentUser?.uid;
          if (uid == null) {
            throw Exception('User not logged in');
          }

          final userDoc = await _databaseService.getUser(uid);
          if (!userDoc.exists) {
            throw Exception('User data not found');
          }

          final role = (userDoc.data() as Map<String, dynamic>)['roles'][0];

          if (!mounted) return;
          if (role == 'mentor') {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.mentorRegistrationScreen,
              arguments: uid,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.menteeOnboardingPage,
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error finding user role: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid or expired OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
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
                    // Optional: Add a loading indicator
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
