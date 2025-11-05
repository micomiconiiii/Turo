import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // 1. Import 'path' package (run 'flutter pub add path')

// 2. Import Firebase packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 6 of the profile setup: "Who are you looking for?"
/// This screen collects the final data and uploads EVERYTHING to Firebase.
class LookingForScreen extends StatefulWidget {
  // --- 3. ACCEPT ALL DATA FROM PREVIOUS STEPS ---
  final File? profileImage;
  final List<String>? expertise;
  final List<String>? goals;
  final List<String>? durations;
  final Map<String, String>? rates; // e.g., {'min': '1000', 'max': '5000'}

  const LookingForScreen({
    super.key,
    // --- 4. ADD ALL TO CONSTRUCTOR ---
    this.profileImage,
    this.expertise,
    this.goals,
    this.durations,
    this.rates,
  });

  @override
  State<LookingForScreen> createState() => _LookingForScreenState();
}

class _LookingForScreenState extends State<LookingForScreen> {
  // List of all available options
  final List<String> _lookingForOptions = [
    'Students',
    'Freelance Developers',
    'Startups',
  ];
  // Map to store the checked state
  Map<String, bool> _selectedOptions = {};
  
  // To show a loading spinner during upload
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    // Initialize the map
    _selectedOptions = {
      for (var option in _lookingForOptions) option: false
    };
  }

  /// Function to FINISH setup and upload all data to Firebase
  Future<void> _finishSetup() async {
    // Show loading spinner and prevent double-taps
    if (_isLoading) return; 
    setState(() {
      _isLoading = true;
    });

    try {
      // --- 5. GET THE CURRENT USER ID (UID) ---
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle error: No user is logged in
        print("Error: No user logged in!");
        if (mounted) setState(() { _isLoading = false; });
        return; // Stop the function
      }
      final uid = user.uid;
      String? downloadURL; // This will hold the URL of the uploaded image

      // --- 6. UPLOAD THE IMAGE TO FIREBASE STORAGE (if one was picked) ---
      if (widget.profileImage != null) {
        // Get the original file's extension (e.g., ".png" or ".jpg")
        final fileExtension = p.extension(widget.profileImage!.path);
            
        // Create the reference with the correct extension
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures') // Folder name
            .child('$uid$fileExtension'); // e.g., 'USER_ID.png'

        print("Attempting to upload to: ${storageRef.fullPath}"); //debug line
        
        // Upload the file
        await storageRef.putFile(widget.profileImage!);

        // Get the public URL of the uploaded image
        downloadURL = await storageRef.getDownloadURL();
      }

      // --- 7. PREPARE ALL DATA TO SAVE ---
      // Get this screen's data
      final selectedLookingFor = _selectedOptions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Create a map (a JSON object) of all the profile data
      final userData = {
        'profilePictureUrl': downloadURL, // The URL from Storage (or null)
        'expertise': widget.expertise ?? [],
        'goals': widget.goals ?? [],
        'durations': widget.durations ?? [],
        'rates': widget.rates ?? {'min': '', 'max': ''},
        'lookingFor': selectedLookingFor,
        'isProfileComplete': true, // A flag to show they finished setup!
      };

      // --- 8. SAVE DATA TO CLOUD FIRESTORE ---
      // Use .set with merge:true to safely create or update the user's document
      await FirebaseFirestore.instance
          .collection('users') // Your main user collection
          .doc(uid) // The specific document for this user
          .set(userData, SetOptions(merge: true)); // Merges this data

      // --- 9. NAVIGATE BACK to MyProfileScreen ---
      if (mounted) { // Check if the widget is still on screen
        // Pop all setup screens until we get back to the first screen (MyProfileScreen)
        Navigator.popUntil(context, (route) => route.isFirst);
      }

    } catch (e) {
      // Handle any errors (show a snackbar, etc.)
      print("Error finishing setup: $e");
      // Optionally show a user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: ${e.toString()}"))
        );
      }
    } finally {
      // Hide loading spinner, even if an error occurred
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a Stack to show a loading overlay on top of the UI
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. HEADER ---
                  const TuroLogoHeader(),
                  const SizedBox(height: 20),
                  const SetupProgressHeader(
                    title: "Who are you looking for?",
                    currentStep: 6,
                  ),
                  const SizedBox(height: 40),

                  // --- 2. MIDDLE CONTENT (Scrollable) ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SetupScreenIcon(icon: Icons.calculate_outlined),
                          const SizedBox(height: 30),
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "I am looking for...",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Tick the boxes below",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // --- Checkbox List ---
                          Column(
                            children: _lookingForOptions.map((option) {
                              return SetupCheckboxTile(
                                label: option,
                                value: _selectedOptions[option]!,
                                onChanged: (bool? newValue) {
                                  // Disable checkbox if loading
                                  if (_isLoading) return;
                                  setState(() {
                                    _selectedOptions[option] = newValue!;
                                  });
                                },
                                onTap: () {
                                  // Disable tap if loading
                                  if (_isLoading) return;
                                  setState(() {
                                    _selectedOptions[option] =
                                        !_selectedOptions[option]!;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 3. FOOTER ---
                  // Disable buttons while loading by passing null to onPressed
                  SetupButtonFooter(
                    onNext: _isLoading ? () {} : _finishSetup,
                    onSkip: _isLoading ? () {} : _finishSetup,
                  ),
                ],
              ),
            ),
          ),

          // --- 4. LOADING SPINNER OVERLAY ---
          // This will only appear if _isLoading is true
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Dark overlay
              child: const Center(
                child: CircularProgressIndicator(), // Loading circle
              ),
            ),
        ],
      ),
    );
  }
}