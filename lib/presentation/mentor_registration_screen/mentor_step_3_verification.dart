import 'dart:io'; // Needed for File on mobile
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/mentor_registration_provider.dart';

class MentorStep3Verification extends StatefulWidget {
  const MentorStep3Verification({super.key});

  @override
  State<MentorStep3Verification> createState() =>
      _MentorStep3VerificationState();
}

class _MentorStep3VerificationState extends State<MentorStep3Verification> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickIdImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (!mounted) return;
      context.read<MentorRegistrationProvider>().updateFiles(idFile: picked);
    }
  }

  Future<void> _pickSelfieImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      if (!mounted) return;
      context.read<MentorRegistrationProvider>().updateFiles(
        selfieFile: picked,
      );
    }
  }

  void _onNextPressed() {
    final provider = context.read<MentorRegistrationProvider>();

    if (provider.idFile == null || provider.selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both your Government ID and a Selfie.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    provider.nextPage();
  }

  Widget _buildUploadCard({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    XFile? imageFile,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF2C6A64),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: imageFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, size: 48, color: const Color(0xFF2C6A64)),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF2C6A64),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          imageFile.path,
                          height: 140,
                          width: 240,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(imageFile.path),
                          height: 140,
                          width: 240,
                          fit: BoxFit.cover,
                        ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MentorRegistrationProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Identity Verification',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C6A64),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildUploadCard(
                label: 'Upload Government ID',
                icon: FontAwesomeIcons.idCard,
                onTap: _pickIdImage,
                imageFile: provider.idFile,
              ),
              _buildUploadCard(
                label: 'Take a Real-time Selfie',
                icon: FontAwesomeIcons.camera,
                onTap: _pickSelfieImage,
                imageFile: provider.selfieFile,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2C6A64),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Next'),
                  onPressed: _onNextPressed,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
