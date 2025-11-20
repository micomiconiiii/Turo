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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isVerifying = true);
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isVerifying = true);

      final otp = _pinController.text.trim();

      // The backend still generates a token/user, but we will decide
      // what to do with it based on the flag below.
      final result = await CustomFirebaseOtpService.verifyEmailOTP(widget.email, otp);
      
      if (!mounted) return;
      setState(() => _isVerifying = false);

      // Assuming your service returns a Map or boolean. 
      // Adjust 'result' check based on your actual service return type.
      // If it returns boolean: if (result)
      // If it returns Map: if (result['success'])
      if (result == true) { 
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green,
        ));

        // --- 2. LOGIC BRANCH ---
        if (widget.isInstitutional) {
          // CASE A: Institutional Verification
          // We do NOT go forward. We go BACK to the form, passing the verified email.
          // We do NOT sign in with the token.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IdUploadScreen(
                user: widget.user,
                userDetail: widget.userDetail,
                
                // THIS IS THE KEY: Pass the verified email forward
                institutionalEmail: widget.email, 
              )
            ),
          );
        } else {
          // CASE B: Primary Registration Flow
          // Your existing logic (Push forward)
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => IdUploadScreen(
                        user: widget.user,
                        userDetail: widget.userDetail,
                      )),
              (route) => false);
        }
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid or expired OTP. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
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
                    final success = await CustomFirebaseOtpService.resendEmailOTP(widget.email);
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