// This screen is for selfie verification during mentor registration (STEP 4 out of 6).
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:turo/core/app_export.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/presentation/mentor_registration_screen/credentials_achievements_screen.dart';
import 'package:turo/widgets/custom_button.dart';
import '../../services/auth_service.dart';

class SelfieVerificationScreen extends StatefulWidget {
  final UserModel user;
  final UserDetailModel userDetail;
  final String? idType;
  final String? idFileName;
  final Uint8List? idFileBytes;
  final String? institutionalEmail; 

  const SelfieVerificationScreen(
  {super.key,
  required this.user,
  required this.userDetail,
  this.institutionalEmail,
  this.idType,
  this.idFileName,
  this.idFileBytes});

  @override
  _SelfieVerificationScreenState createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen> {
  final AuthService _authService = AuthService();
  XFile? _pickedFile;
  UploadTask? _uploadTask;

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _pickedFile = image;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CredentialsAchievementsScreen(
          user: widget.user,
          userDetail: widget.userDetail,
          institutionalEmail: widget.institutionalEmail,
          selfieFile: _pickedFile,
          idType: widget.idType,
          idFileName: widget.idFileName,
          idFileBytes: widget.idFileBytes,
        ),
      ),
    );
  }

  void _onSkipPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CredentialsAchievementsScreen(
          user: widget.user,
          userDetail: widget.userDetail,
          institutionalEmail: widget.institutionalEmail,
          idType: widget.idType,
          idFileName: widget.idFileName,
          idFileBytes: widget.idFileBytes,
          selfieFile: null, // Explicitly pass null for selfie
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.blue_gray_700),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                text: 'Next',
                onPressed: _pickedFile != null ? _uploadFile : null,
                isExpanded: true,
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Skip',
                onPressed: _onSkipPressed,
                backgroundColor: Colors.transparent,
                textColor: appTheme.blue_gray_700,
                isExpanded: true,
              ),
            ],
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
                    'Step 4 out of 6',
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(height: 1.5),
                  ),
                ],
              ),

              // ---- PROGRESS BAR ----
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),

                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  Expanded(
                    child: Row(
                      children: List.generate(
                        2,
                        (i) => Expanded(
                          child: Container(
                            height: 6.h,
                            margin: EdgeInsets.only(right: i == 2 ? 0 : 2.h),
                            decoration: BoxDecoration(
                              color: appTheme.blue_gray_100,
                              borderRadius: BorderRadius.circular(3.h),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              Center(
                child: Text(
                  'Selfie Verification',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
              ),
              Center(
                child: Text(
                  'Take a selfie to verify your identity',
                  style: TextStyleHelper.instance.body12RegularFustat.copyWith(
                    color: appTheme.gray_800,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Center(
                child: CircleAvatar(
                  radius: 100.h,
                  backgroundColor: appTheme.blue_gray_100.withOpacity(0.3),
                  backgroundImage: _pickedFile != null
                      ? (kIsWeb
                          ? NetworkImage(_pickedFile!.path)
                          : FileImage(File(_pickedFile!.path))) as ImageProvider
                      : null,
                  child: _pickedFile == null
                      ? Icon(
                          Icons.camera_alt_outlined,
                          size: 80.h,
                          color: appTheme.blue_gray_700,
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20.h),

              Center(
                child: CustomButton(
                  text: 'Open Camera',
                  onPressed: _takePicture,
                  width: 200.h,
                ),
              ),

              if (_uploadTask != null)
                StreamBuilder<TaskSnapshot>(
                  stream: _uploadTask!.snapshotEvents,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final progress =
                          snapshot.data!.bytesTransferred /
                          snapshot.data!.totalBytes;
                      return Column(
                        children: [
                          SizedBox(height: 20.h),
                          LinearProgressIndicator(value: progress),
                          SizedBox(height: 10.h),
                          Text('${(progress * 100).toStringAsFixed(2)}%'),
                        ],
                      );
                    }
                    return Container();
                  },
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
