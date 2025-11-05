// Import Flutter's material library
import 'package:flutter/material.dart';
import 'dart:io'; // <-- 1. ADD THIS IMPORT for File

// Import the next screen in the flow
import 'rates_setup_screen.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 4 of the profile setup: "Select duration."
class DurationSetupScreen extends StatefulWidget {
  // --- 2. ADD PARAMETERS from previous steps ---
  final File? profileImage;
  final List<String>? expertise;
  final List<String>? goals;

  const DurationSetupScreen({
    super.key,
    // --- 3. ADD TO CONSTRUCTOR ---
    this.profileImage,
    this.expertise,
    this.goals,
  });

  @override
  State<DurationSetupScreen> createState() => _DurationSetupScreenState();
}

class _DurationSetupScreenState extends State<DurationSetupScreen> {
  final List<String> _durationOptions = [
    'Long-term Mentorship',
    'Short-term Mentorship',
    'Milestone-based Mentorship',
  ];
  Map<String, bool> _selectedDurations = {};

  @override
  void initState() {
    super.initState();
    _selectedDurations = {
      for (var option in _durationOptions) option: false
    };
  }

  /// Navigates the user to the next step (RatesSetupScreen)
  void _goToNextStep() {
    // Get this screen's data
    final selected = _selectedDurations.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print("Selected durations: $selected");

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        // --- 4. PASS ALL DATA FORWARD ---
        builder: (context) => RatesSetupScreen(
          profileImage: widget.profileImage, // from Step 1
          expertise: widget.expertise,       // from Step 2
          goals: widget.goals,             // from Step 3
          durations: selected,             // from Step 4 (this screen)
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
                title: "Select duration.",
                currentStep: 4,
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SetupScreenIcon(icon: Icons.timer_outlined),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Mentorship Duration",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Select below the duration you aim for the mentorship",
                              textAlign: TextAlign.center,
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
                        children: _durationOptions.map((duration) {
                          return SetupCheckboxTile(
                            label: duration,
                            value: _selectedDurations[duration]!,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _selectedDurations[duration] = newValue!;
                              });
                            },
                            onTap: () {
                              setState(() {
                                _selectedDurations[duration] =
                                    !_selectedDurations[duration]!;
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