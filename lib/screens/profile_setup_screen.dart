// Import necessary packages for Flutter UI, image picking, and file handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import the next screen in the setup flow
import 'expertise_setup_screen.dart';

// Import the reusable widgets
import '../widgets/common_widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // A nullable 'File' variable to store the path of the image the user picks.
  File? _image;

  // An instance of ImagePicker to handle opening the gallery
  final picker = ImagePicker();

  /// Asynchronous function to open the device's image gallery and pick an image.
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Navigates the user to the next step in the profile setup
  void _goToNextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // --- PASS DATA FORWARD ---
        // Pass the selected image file to the next screen
        builder: (context) => ExpertiseSetupScreen(
          profileImage: _image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Reusable Header ---
              const TuroLogoHeader(),
              const SizedBox(height: 20),
              const SetupProgressHeader(
                title: "Complete your profile",
                currentStep: 1,
              ),
              const SizedBox(height: 40),

              // --- 2. Screen-Specific Content ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF1B4D44),
                    child: _image == null
                        ? const Icon(Icons.camera_alt,
                            color: Colors.white, size: 45)
                        : ClipOval(
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Upload your Profile Picture",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Make sure that it looks professional!",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Choose your profile picture",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    _image == null ? "Upload your picture" : "Picture selected",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const Spacer(),

              // --- 3. Reusable Footer ---
              SetupButtonFooter(
                onNext: _goToNextStep,
                onSkip: _goToNextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}