// This screen is for adding credentials and achievements during mentor registration (STEP 5 out of 6).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:turo/core/app_export.dart';
import 'package:turo/widgets/custom_button.dart';

class CredentialsAchievementsScreen extends StatefulWidget {
  const CredentialsAchievementsScreen({super.key});

  @override
  _CredentialsAchievementsScreenState createState() =>
      _CredentialsAchievementsScreenState();
}

class _CredentialsAchievementsScreenState
    extends State<CredentialsAchievementsScreen> {
  final List<Credential> _credentials = [];
  final List<Achievement> _achievements = [];

  void _addCredential(Credential credential) {
    setState(() {
      _credentials.add(credential);
    });
  }

  void _addAchievement(Achievement achievement) {
    setState(() {
      _achievements.add(achievement);
    });
  }

  Future<void> _showAddCredentialDialog() async {
    final result = await showDialog<Credential>(
      context: context,
      builder: (context) => const AddCredentialAchievementDialog(
        title: 'Add Credential',
      ),
    );
    if (result != null) {
      _addCredential(result);
    }
  }

  Future<void> _showAddAchievementDialog() async {
    final result = await showDialog<Achievement>(
      context: context,
      builder: (context) => const AddCredentialAchievementDialog(
        title: 'Add Achievement',
      ),
    );
    if (result != null) {
      _addAchievement(result);
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                text: 'Submit',
                onPressed: () {
                  // TODO: Handle submit
                },
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Skip',
                onPressed: () {
                  // TODO: Handle skip
                },
                backgroundColor: Colors.transparent,
                textColor: appTheme.blue_gray_700,
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
                    'Step 5 out of 6',
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
                        color: index < 5
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
                child: Text(
                  'Credentials & Achievements',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
              ),

              SizedBox(height: 32.h),

              _buildSection(
                title: 'Credentials',
                onAdd: _showAddCredentialDialog,
                items: _credentials,
              ),

              SizedBox(height: 32.h),

              _buildSection(
                title: 'Achievements',
                onAdd: _showAddAchievementDialog,
                items: _achievements,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onAdd,
    required List<dynamic> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyleHelper.instance.title20SemiBoldFustat
                  .copyWith(color: appTheme.gray_800, height: 1.45),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAdd,
              color: appTheme.blue_gray_700,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (items.isEmpty)
          const Text('No items added yet.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text('Year: \${item.year}'),
                  trailing: item.certificateFileName != null
                      ? const Icon(Icons.attachment)
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }
}

class AddCredentialAchievementDialog extends StatefulWidget {
  final String title;

  const AddCredentialAchievementDialog({super.key, required this.title});

  @override
  _AddCredentialAchievementDialogState createState() =>
      _AddCredentialAchievementDialogState();
}

class _AddCredentialAchievementDialogState
    extends State<AddCredentialAchievementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  String? _fileName;
  Uint8List? _fileBytes;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          if (kIsWeb) {
            _fileBytes = result.files.single.bytes;
          } else {
            _fileBytes = File(result.files.single.path!).readAsBytesSync();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: \${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year Achieved'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a year';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.h),
                  decoration: BoxDecoration(
                    color: appTheme.blue_gray_100.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.h),
                    border: Border.all(
                      color: appTheme.blue_gray_100,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _fileBytes != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        size: 48.h,
                        color: _fileBytes != null
                            ? Colors.green
                            : appTheme.blue_gray_700,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _fileBytes != null
                            ? _fileName ?? 'File uploaded'
                            : 'Upload Certificate (Optional)',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final result = widget.title == 'Add Credential'
                  ? Credential(
                      title: _titleController.text,
                      year: int.parse(_yearController.text),
                      certificateBytes: _fileBytes,
                      certificateFileName: _fileName,
                    )
                  : Achievement(
                      title: _titleController.text,
                      year: int.parse(_yearController.text),
                      certificateBytes: _fileBytes,
                      certificateFileName: _fileName,
                    );
              Navigator.of(context).pop(result);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class Credential {
  final String title;
  final int year;
  final Uint8List? certificateBytes;
  final String? certificateFileName;

  Credential({
    required this.title,
    required this.year,
    this.certificateBytes,
    this.certificateFileName,
  });
}

class Achievement {
  final String title;
  final int year;
  final Uint8List? certificateBytes;
  final String? certificateFileName;

  Achievement({
    required this.title,
    required this.year,
    this.certificateBytes,
    this.certificateFileName,
  });
}
