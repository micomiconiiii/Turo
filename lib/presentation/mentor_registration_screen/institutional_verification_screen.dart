// This screen is for institutional verification during mentor registration (STEP 2 out of 6).
import 'package:flutter/material.dart';
import 'package:turo/presentation/mentor_registration_screen/id_upload_screen.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_button.dart';
import '../../services/custom_firebase_otp_service.dart';
import './otp_verification_screen.dart';

enum ButtonVariant { fillPrimary, outlineBlack }

class InstitutionalVerificationScreen extends StatefulWidget {
  const InstitutionalVerificationScreen({super.key});

  @override
  State<InstitutionalVerificationScreen> createState() =>
      _InstitutionalVerificationScreenState();
}

class _InstitutionalVerificationScreenState
    extends State<InstitutionalVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();

  void _onSendOTPPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      final emailAddress = _emailController.text;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final success = await CustomFirebaseOtpService.requestEmailOTP(
          emailAddress,
        );
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent to $emailAddress'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                email: emailAddress,
                onVerificationSuccess: () {
                  // Navigate to ID Upload screen after successful institutional verification
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => IdUploadScreen()),
                  );
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send OTP. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSkipPressed() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => IdUploadScreen()));
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _emailController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TURO',
                style: TextStyleHelper.instance.headline32SemiBoldFustat
                    .copyWith(height: 1.44),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mentor Registration',
                    style: TextStyleHelper.instance.title20SemiBoldFustat
                        .copyWith(color: appTheme.gray_800, height: 1.45),
                  ),
                  Text(
                    'Step 2 out of 6',
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(height: 1.5),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProgressSegment(filled: true),
                    SizedBox(width: 2.h),
                    _buildProgressSegment(filled: true),
                    SizedBox(width: 2.h),
                    _buildProgressSegment(filled: false),
                    SizedBox(width: 2.h),
                    _buildProgressSegment(filled: false),
                    SizedBox(width: 2.h),
                    _buildProgressSegment(filled: false),
                    SizedBox(width: 2.h),
                    _buildProgressSegment(filled: false),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: Container(
                  height: 100.h,
                  width: 100.h,
                  decoration: BoxDecoration(
                    color: appTheme.blue_gray_700,
                    borderRadius: BorderRadius.circular(50.h),
                  ),
                  child: Center(
                    child: CustomImageView(
                      imagePath: ImageConstant.imgPath184,
                      height: 50.h,
                      width: 50.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  'Verify your Institution',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
              ),
              Center(
                child: Text(
                  'Turo will send a verification code to verify your affiliation with the organization',
                  style: TextStyleHelper.instance.body12RegularFustat.copyWith(
                    color: appTheme.gray_800,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomEditText(
                      controller: _institutionController,
                      placeholder: 'Institution/Organization',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your institution';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomEditText(
                      controller: _emailController,
                      placeholder: 'Institutional Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your institutional email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        final domain = value.split('@').last.toLowerCase();
                        final personalDomains = [
                          'gmail.com',
                          'yahoo.com',
                          'hotmail.com',
                          'outlook.com',
                          'icloud.com',
                          'aol.com',
                        ];
                        if (personalDomains.contains(domain)) {
                          return 'Please use your institutional email, not a personal email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomEditText(
                      controller: _jobController,
                      placeholder: 'Job Description',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your job description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              CustomButton(
                text: 'Send OTP',
                onPressed: _onSendOTPPressed,
                backgroundColor: appTheme.blue_gray_700,
                textColor: Colors.white,
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Skip',
                onPressed: _onSkipPressed,
                backgroundColor: Colors.transparent,
                textColor: appTheme.blue_gray_700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSegment({required bool filled}) {
    return Container(
      height: 6.h,
      width: 52.h,
      decoration: BoxDecoration(
        color: filled ? appTheme.blue_gray_700 : appTheme.blue_gray_100,
        borderRadius: BorderRadius.circular(3.h),
      ),
    );
  }
}
