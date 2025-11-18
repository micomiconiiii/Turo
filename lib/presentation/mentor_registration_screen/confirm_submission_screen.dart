import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/presentation/mentor_registration_screen/credentials_achievements_screen.dart';
import 'package:turo/services/profile_service.dart';
import 'package:turo/core/app_export.dart';
import 'package:turo/widgets/custom_button.dart';

class ConfirmSubmissionScreen extends StatefulWidget {
  final UserModel user;
  final UserDetailModel userDetail;
  final XFile? selfieFile;
  final List<Credential> credentials;
  final List<Achievement> achievements;
  final String? idType;
  final String? idFileName;
  final String? institutionalEmail;
  final Uint8List? idFileBytes;

  const ConfirmSubmissionScreen(
      {super.key,
      required this.user,
      required this.userDetail,
      this.selfieFile,
      required this.credentials,
      required this.achievements,
      this.idType,
      this.institutionalEmail, 
      this.idFileName,
      this.idFileBytes});

  @override
  State<ConfirmSubmissionScreen> createState() =>
      _ConfirmSubmissionScreenState();
}

class _ConfirmSubmissionScreenState extends State<ConfirmSubmissionScreen> {
  bool _isLoading = false;
  final ProfileService _profileService = ProfileService();

  Future<void> _saveProfileData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _profileService.saveUserProfile(
        widget.user,
        widget.userDetail,
        selfieFile: widget.selfieFile,
        idType: widget.idType,
        idFileName: widget.idFileName,
        idFileBytes: widget.idFileBytes,
        credentials: widget.credentials,
        institutionalEmail: widget.institutionalEmail,
        achievements: widget.achievements,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile information saved successfully!'),
            backgroundColor: appTheme.blue_gray_700,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.appNavigationScreen, (route) => false);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h, left: 20.h, right: 20.h),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: 'Confirm Submission',
                  onPressed: () => _saveProfileData(context),
                ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- HEADER ----
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
                    'Step 6 out of 6',
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(height: 1.5),
                  ),
                ],
              ),

              // ---- PROGRESS BAR ----
              SizedBox(height: 8.h),
              Row(
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: Container(
                      height: 6.h,
                      margin: EdgeInsets.only(right: index == 5 ? 0 : 2.h),
                      decoration: BoxDecoration(
                        color: appTheme.blue_gray_700,
                        borderRadius: BorderRadius.circular(3.h),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              Center(
                child: Text(
                  'Confirm Submission',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Please review your information before submitting.',
                style: TextStyleHelper.instance.body12RegularFustat
                    .copyWith(color: appTheme.gray_800, height: 1.5),
              ),
              SizedBox(height: 16.h),
              _buildReviewField('Full Name', widget.user.displayName),
              _buildReviewField('Email', widget.userDetail.email ?? 'N/A'),
              _buildReviewField('Bio', widget.user.bio ?? ''),
              _buildReviewField('Address', widget.userDetail.address ?? ''),
              if (widget.selfieFile != null)
                _buildReviewField('Selfie', 'Image selected'),
              if (widget.credentials.isNotEmpty)
                _buildReviewField(
                    'Credentials',
                    widget.credentials
                        .map((e) => e.title)
                        .join(', ')),
              if (widget.achievements.isNotEmpty)
                _buildReviewField(
                    'Achievements',
                    widget.achievements
                        .map((e) => e.title)
                        .join(', ')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyleHelper.instance.body12RegularFustat
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyleHelper.instance.body12RegularFustat,
          ),
        ],
      ),
    );
  }
}