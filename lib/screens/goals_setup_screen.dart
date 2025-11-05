// Import Flutter's material library
import 'package:flutter/material.dart';
import 'dart:io'; // <-- ADDED for File

// Import the next screen in the flow
import 'duration_setup_screen.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 3 of the profile setup: "What are your goals?"
class GoalsSetupScreen extends StatefulWidget {
  // --- ADDED THIS ---
  final File? profileImage;
  final List<String>? expertise;

  const GoalsSetupScreen({
    super.key,
    this.profileImage, // Added to constructor
    this.expertise,    // Added to constructor
  });

  @override
  State<GoalsSetupScreen> createState() => _GoalsSetupScreenState();
}

class _GoalsSetupScreenState extends State<GoalsSetupScreen> {
  // List of all available goal options
  final List<String> _goalOptions = [
    'Career Development',
    'Business Consultation',
    'Academics',
    'Personal Growth',
  ];

  // Map to store the checked state
  Map<String, bool> _selectedGoals = {};

  @override
  void initState() {
    super.initState();
    _selectedGoals = {for (var option in _goalOptions) option: false};
  }

  /// Navigates the user to the next step
  void _goToNextStep() {
    // Get this screen's data
    final selected = _selectedGoals.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    print("Selected goals: $selected");

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        // --- PASS DATA FORWARD ---
        builder: (context) => DurationSetupScreen(
          profileImage: widget.profileImage, // from Step 1
          expertise: widget.expertise,    // from Step 2
          goals: selected,                // from Step 3
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
                title: "What are your goals?",
                currentStep: 3,
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SetupScreenIcon(icon: Icons.assignment_ind_outlined),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Mentorship Goals",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Select the goals you want to focus on.",
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
                        children: _goalOptions.map((goal) {
                          return SetupCheckboxTile(
                            label: goal,
                            value: _selectedGoals[goal]!,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _selectedGoals[goal] = newValue!;
                              });
                            },
                            onTap: () {
                              setState(() {
                                _selectedGoals[goal] =
                                    !_selectedGoals[goal]!;
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