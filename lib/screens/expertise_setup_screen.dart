// Import Flutter's material library
import 'package:flutter/material.dart';
import 'dart:io'; // <-- ADDED for File

// Import the next screen in the flow
import 'goals_setup_screen.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 2 of the profile setup: "What are your expertise?"
class ExpertiseSetupScreen extends StatefulWidget {
  // --- ADDED THIS ---
  final File? profileImage; // Accepts image from Step 1

  const ExpertiseSetupScreen({
    super.key,
    this.profileImage, // Added to constructor
  });

  @override
  State<ExpertiseSetupScreen> createState() => _ExpertiseSetupScreenState();
}

class _ExpertiseSetupScreenState extends State<ExpertiseSetupScreen> {
  // List of all available expertise options
  final List<String> _expertiseOptions = [
    'Software Technology',
    'Entrepreneurship',
    'Digital Marketing',
    'App Development',
    'Business Intelligence',
  ];

  // Map to store the checked state
  Map<String, bool> _selectedExpertise = {};

  @override
  void initState() {
    super.initState();
    _selectedExpertise = {
      for (var option in _expertiseOptions) option: false
    };
  }

  /// Navigates the user to the next step
  void _goToNextStep() {
    // Get this screen's data
    final selected = _selectedExpertise.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    print("Selected expertise: $selected");

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        // --- PASS DATA FORWARD ---
        builder: (context) => GoalsSetupScreen(
          profileImage: widget.profileImage, // Pass image from Step 1
          expertise: selected,                // Pass expertise from Step 2
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // (The build method remains exactly the same, using the common widgets)
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER ---
              const TuroLogoHeader(),
              const SizedBox(height: 20),
              const SetupProgressHeader(
                title: "What are your expertise?",
                currentStep: 2,
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SetupScreenIcon(icon: Icons.science_outlined),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Expertise",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Tick the boxes below that match your expertise.",
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
                        children: _expertiseOptions.map((expertise) {
                          return SetupCheckboxTile(
                            label: expertise,
                            value: _selectedExpertise[expertise]!,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _selectedExpertise[expertise] = newValue!;
                              });
                            },
                            onTap: () {
                              setState(() {
                                _selectedExpertise[expertise] =
                                    !_selectedExpertise[expertise]!;
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