// This screen is for selfie verification during mentor registration (STEP 4 out of 6).
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:turo/core/app_export.dart';
import 'package:turo/widgets/custom_button.dart';

class SelfieVerificationScreen extends StatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  _SelfieVerificationScreenState createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen> {
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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final fileName = 'selfie_verification/${DateTime.now().millisecondsSinceEpoch}';
    final destination = 'users/${user.uid}/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(await _pickedFile!.readAsBytes());
      } else {
        uploadTask = ref.putFile(File(_pickedFile!.path));
      }
      setState(() {
        _uploadTask = uploadTask;
      });

      final snapshot = await _uploadTask!.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      // Save the download URL to the user's profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'selfieVerification': {
          'downloadUrl': url,
          'uploadedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selfie uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the next screen
      Navigator.pushNamed(context, AppRoutes.credentialsAchievementsScreen);

      setState(() {
        _uploadTask = null;
      });
    } catch (e) {
      print('Error uploading file: $e');
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
          child: CustomButton(
            text: 'Upload',
            onPressed: _pickedFile != null ? _uploadFile : null,
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
                  style: TextStyleHelper.instance.body12RegularFustat
                      .copyWith(color: appTheme.gray_800, height: 1.5),
                ),
              ),

              SizedBox(height: 20.h),

              if (_pickedFile != null)
                Center(
                  child: kIsWeb
                      ? Image.network(
                          _pickedFile!.path,
                          height: 200,
                        )
                      : Image.file(
                          File(_pickedFile!.path),
                          height: 200,
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
                          snapshot.data!.bytesTransferred / snapshot.data!.totalBytes;
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
