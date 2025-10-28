import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:turo/core/app_export.dart';
import 'package:turo/widgets/custom_button.dart';

class IdUploadScreen extends StatefulWidget {
  @override
  _IdUploadScreenState createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  PlatformFile? _pickedFile;
  UploadTask? _uploadTask;
  String? _selectedIdType;

  final List<String> _idTypes = [
    'Philippine Passport',
    'Driver\'s License',
    'Social Security System (SSS) Card',
    'Unified Multi-Purpose ID (UMID)',
    'Postal ID',
    'Voter\'s ID',
    'Professional Regulation Commission (PRC) ID',
    'National ID (PhilSys)',
    'Senior Citizen ID',
    'Student ID',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFile = result.files.single;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_pickedFile == null || _selectedIdType == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not signed in');
      // Optionally, show a message to the user
      return;
    }

    final fileName = 'id_verification/$_selectedIdType/${DateTime.now().millisecondsSinceEpoch}';
    final destination = 'users/${user.uid}/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      setState(() {
        if (kIsWeb) {
          _uploadTask = ref.putData(_pickedFile!.bytes!);
        } else {
          _uploadTask = ref.putFile(File(_pickedFile!.path!));
        }
      });

      final snapshot = await _uploadTask!.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      // Save the download URL and ID type to the user's profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'idVerification': {
          'idType': _selectedIdType,
          'downloadUrl': url,
          'uploadedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      print('Download URL: $url');
      print('ID Type: $_selectedIdType');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the next screen
      Navigator.pushNamed(context, AppRoutes.selfieVerificationScreen);

      setState(() {
        _uploadTask = null;
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> dropdownItems = _idTypes.map((String idType) {
      return DropdownMenuItem<String>(
        value: idType,
        child: Text(idType),
      );
    }).toList();

    return Scaffold(
      backgroundColor: appTheme.white_A700,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h, left: 20.h, right: 20.h),
          child: CustomButton(
            text: 'Next',
            onPressed: _uploadFile,
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
                  Expanded(
                    child: Row(
                      children: List.generate(
                        4,
                        (i) => Expanded(
                          child: Container(
                            height: 6.h,
                            margin: EdgeInsets.only(right: i == 3 ? 0 : 2.h),
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
                  'ID Verification',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
              ),
              Center(
                child: Text(
                  'Upload a government-issued ID to verify your identity',
                  style: TextStyleHelper.instance.body12RegularFustat
                      .copyWith(color: appTheme.gray_800, height: 1.5),
                ),
              ),

              SizedBox(height: 20.h),

              // ---- ID Type Dropdown ----
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'ID Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedIdType,
                items: dropdownItems,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedIdType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select an ID type' : null,
              ),

              SizedBox(height: 20.h),

              if (_pickedFile != null)
                Center(
                  child: kIsWeb
                      ? Image.memory(
                          _pickedFile!.bytes!,
                          height: 200,
                        )
                      : Image.file(
                          File(_pickedFile!.path!),
                          height: 200,
                        ),
                ),

              SizedBox(height: 20.h),

              Center(
                child: CustomButton(
                  text: 'Pick a file',
                  onPressed: _selectedIdType != null ? _pickFile : null,
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