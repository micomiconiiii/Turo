import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:turo/presentation/mentee_onboarding/providers/mentee_onboarding_provider.dart';

class ProfilePictureStep extends StatefulWidget {
  const ProfilePictureStep({super.key});

  @override
  State<ProfilePictureStep> createState() => ProfilePictureStepState();
}

class ProfilePictureStepState extends State<ProfilePictureStep> {
  final ImagePicker _picker = ImagePicker();

  File? _imageFile; // Mobile/desktop file handle
  Uint8List? _imageBytes; // Web bytes

  File? get imageFile => _imageFile;
  Uint8List? get imageBytes => _imageBytes;

  @override
  void initState() {
    super.initState();
    // Restore state from provider (for back navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MenteeOnboardingProvider>(
        context,
        listen: false,
      );
      setState(() {
        _imageFile = provider.profilePictureFile;
        _imageBytes = provider.profilePictureBytes;
      });
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null || !mounted) return;

    final provider = Provider.of<MenteeOnboardingProvider>(
      context,
      listen: false,
    );

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageFile = null;
      });
      // Save to provider
      provider.setProfilePictureData(bytes: bytes);
    } else {
      final file = File(picked.path);
      setState(() {
        _imageFile = file;
        _imageBytes = null;
      });
      // Save to provider
      provider.setProfilePictureData(file: file);
    }
  }

  /// Called by the parent stepper when the user presses Next.
  /// Just validates that the step is complete (always true for this optional step).
  /// Upload happens later on confirmation.
  Future<bool> validateStep() async {
    // This step is optional, so always return true
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2C6A64);

    Widget preview;
    if (_imageFile != null) {
      preview = CircleAvatar(
        radius: 120,
        backgroundImage: FileImage(_imageFile!),
      );
    } else if (_imageBytes != null) {
      preview = CircleAvatar(
        radius: 120,
        backgroundImage: MemoryImage(_imageBytes!),
      );
    } else {
      preview = CircleAvatar(
        radius: 120,
        backgroundColor: darkGreen.withValues(alpha: 0.1),
        child: const Icon(
          Icons.camera_alt_outlined,
          size: 64,
          color: Colors.black54,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Simple header without icon
          const Text(
            'Upload your Profile Picture',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a photo from gallery or take a selfie.',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Image preview
          Center(child: preview),
          const SizedBox(height: 24),
          // Pick buttons (side by side) when no image selected
          if (_imageFile == null && _imageBytes == null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pick from Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkGreen,
                      side: BorderSide(color: darkGreen, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Take a Selfie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkGreen,
                      side: BorderSide(color: darkGreen, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          // Replace/Clear buttons (show when image is selected)
          if (_imageFile != null || _imageBytes != null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Replace Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Retake Selfie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkGreen,
                      side: BorderSide(color: darkGreen, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Clear button
            TextButton.icon(
              onPressed: () {
                final provider = Provider.of<MenteeOnboardingProvider>(
                  context,
                  listen: false,
                );
                provider.clearProfilePictureData();
                setState(() {
                  _imageFile = null;
                  _imageBytes = null;
                });
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Remove Photo',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Tip: You can skip this step and add a photo later.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
