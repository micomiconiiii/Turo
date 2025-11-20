// This screen is for ID upload during mentor registration (STEP 3 out of 6).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/presentation/mentor_registration_screen/selfie_verification_screen.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';

class IdUploadScreen extends StatefulWidget {
  final UserModel user;
  final UserDetailModel userDetail;
  final String? institutionalEmail;

  const IdUploadScreen({
    super.key,
    required this.user,
    required this.userDetail,
    this.institutionalEmail,
  });

  @override
  State<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIdType;
  File? _uploadedFile;
  Uint8List? _uploadedFileBytes;
  String? _fileName;

  final List<String> _idTypes = [
    'National ID',
    'Driver\'s License',
    'Passport',
    'School ID',
    'Company ID',
    'Government ID',
  ];

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          if (kIsWeb) {
            _uploadedFileBytes = result.files.single.bytes;
          } else {
            _uploadedFile = File(result.files.single.path!);
          }
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNextPressed() {
    if (_uploadedFile == null && _uploadedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfieVerificationScreen(
          user: widget.user,
          userDetail: widget.userDetail,
          idType: _selectedIdType,
          idFileName: _fileName,
          idFileBytes: _uploadedFileBytes,
          institutionalEmail: widget.institutionalEmail,
        ),
      ),
    );

    print('Next pressed - ID Type: $_selectedIdType, File: $_fileName');
  }

  void _onSkipPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfieVerificationScreen(
          user: widget.user,
          userDetail: widget.userDetail,
          institutionalEmail: widget.institutionalEmail,
        ),
      ),
    );
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
                    'Step 3 out of 6',
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(height: 1.5),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              Row(
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: Container(
                      height: 6.h,
                      margin: EdgeInsets.only(right: index == 5 ? 0 : 2.h),
                      decoration: BoxDecoration(
                        color: index < 3
                            ? appTheme.blue_gray_700
                            : appTheme.blue_gray_100,
                        borderRadius: BorderRadius.circular(3.h),
                      ),
                    ),
                  ),
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
                    child: Icon(
                      Icons.badge_outlined,
                      size: 50.h,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              Center(
                child: Text(
                  'Upload Valid ID',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Text(
                    'Please select your ID type and upload a clear photo of your valid identification document',
                    textAlign: TextAlign.center,
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(color: appTheme.gray_800, height: 1.5),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.h),
                        border: Border.all(color: appTheme.blue_gray_100),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedIdType,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.h, vertical: 14.h),
                          border: InputBorder.none,
                          hintText: 'Select ID Type',
                          hintStyle: TextStyleHelper.instance.body12RegularFustat
                              .copyWith(color: appTheme.gray_800),
                        ),
                        items: _idTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyleHelper.instance.body12RegularFustat
                                  .copyWith(color: appTheme.gray_800),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedIdType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an ID type';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: 32.h, horizontal: 16.h),
                        decoration: BoxDecoration(
                          color: appTheme.blue_gray_100.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.h),
                          border: Border.all(
                            color: appTheme.blue_gray_100,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _uploadedFile != null ||
                                      _uploadedFileBytes != null
                                  ? Icons.check_circle
                                  : Icons.cloud_upload_outlined,
                              size: 48.h,
                              color: _uploadedFile != null ||
                                      _uploadedFileBytes != null
                                  ? Colors.green
                                  : appTheme.blue_gray_700,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _uploadedFile != null ||
                                      _uploadedFileBytes != null
                                  ? _fileName ?? 'File uploaded'
                                  : 'Click to upload ID',
                              style: TextStyleHelper.instance
                                  .body12RegularFustat
                                  .copyWith(
                                      color: appTheme.gray_800,
                                      fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Supported formats: JPG, PNG, PDF',
                              style: TextStyleHelper.instance
                                  .body12RegularFustat
                                  .copyWith(color: appTheme.gray_800),
                              textAlign: TextAlign.center,
                            ),
                            if (_uploadedFile != null ||
                                _uploadedFileBytes != null) ...[
                              SizedBox(height: 8.h),
                              TextButton.icon(
                                onPressed: _pickFile,
                                icon: Icon(Icons.refresh, size: 16.h),
                                label: Text('Change File'),
                                style: TextButton.styleFrom(
                                  foregroundColor: appTheme.blue_gray_700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              Center(
                child: CustomButton(
                  text: 'Next',
                  onPressed: _onNextPressed,
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
    );
  }
}
