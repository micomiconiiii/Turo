// This screen is for institutional verification during mentor registration (STEP 2 out of 6).
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turo/presentation/mentor_registration_screen/id_upload_screen.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../services/custom_firebase_otp_service.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';
import 'otp_verification_screen.dart';
import '../../widgets/custom_edit_text.dart';

enum ButtonVariant { fillPrimary, outlineBlack }

class InstitutionalVerificationScreen extends StatefulWidget {
  final UserModel user;
  final UserDetailModel userDetail;
  
  const InstitutionalVerificationScreen({
    super.key, 
    required this.user, 
    required this.userDetail
  });

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
      // 1. Capture the input
      final institutionalEmailInput = _emailController.text.trim();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 2. Request OTP
        final success = await CustomFirebaseOtpService.requestEmailOTP(institutionalEmailInput);
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'OTP sent to $institutionalEmailInput',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.fromLTRB(20.h, 5.h, 20.h, 20.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.h)),
            ),
          );
          
          // 3. Navigate with Correct Arguments
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                email: institutionalEmailInput,
                user: widget.user,
                userDetail: widget.userDetail, 
                isInstitutional: true, 
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to send OTP. Please try again.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(20.h, 5.h, 20.h, 20.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.h)),
          ),
        );
      }
    }
  } 
  void _onSkipPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IdUploadScreen(
          user: widget.user,
          userDetail: widget.userDetail,
          institutionalEmail: null, 
        ),
      ),
    );
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CustomButton(
                  text: 'Send OTP',
                  onPressed: _onSendOTPPressed,
                  backgroundColor: appTheme.blue_gray_700,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: CustomButton(
                  text: 'Skip',
                  onPressed: _onSkipPressed,
                  backgroundColor: Colors.transparent,
                  textColor: appTheme.blue_gray_700,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: appTheme.white_A700,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: appTheme.blue_gray_700),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 16.h),
                  Text(
                    'TURO',
                    style: TextStyleHelper.instance.headline32SemiBoldFustat
                        .copyWith(height: 1.44),
                  ),
                ],
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
                    child: FaIcon(
                      FontAwesomeIcons.buildingColumns,
                      size: 50.h,
                      color: Colors.white,
                    ), // Using a ready-made vector icon
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
                  style: TextStyleHelper.instance.body12RegularFustat.copyWith(color: appTheme.gray_800, height: 1.5),
                  textAlign: TextAlign.center, 
                ),
              ),
              SizedBox(height: 32.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomEditText(
                      controller: _institutionController,
                      labelText: 'Institution/Organization',
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
                      labelText: 'Institutional Email',
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
                      labelText: 'Job Description',
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