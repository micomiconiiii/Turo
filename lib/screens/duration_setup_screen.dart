// Import Flutter's material library
import 'package:flutter/material.dart';

// Import the next screen in the flow
import 'rates_setup_screen.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 4 of the profile setup: "Select duration."
/// This is a StatefulWidget because it needs to store the state
/// of the checkboxes.
class DurationSetupScreen extends StatefulWidget {
  const DurationSetupScreen({super.key});

  @override
  State<DurationSetupScreen> createState() => _DurationSetupScreenState();
}

class _DurationSetupScreenState extends State<DurationSetupScreen> {
  // 1. List of all available duration options
  final List<String> _durationOptions = [
    'Long-term Mentorship',
    'Short-term Mentorship',
    'Milestone-based Mentorship',
  ];

  // 2. Map to store the checked state (true/false) of each option
  Map<String, bool> _selectedDurations = {};

  /// This function runs once when the widget is first created.
  @override
  void initState() {
    super.initState();
    // 3. Initialize the map, setting all options to 'false' (unchecked)
    _selectedDurations = {
      for (var option in _durationOptions) option: false
    };
  }

  // 4. We no longer need the _buildDurationTile method,
  //    as this logic is now inside `SetupCheckboxTile`.

  /// Navigates the user to the next step (RatesSetupScreen)
  void _goToNextStep() {
    // First, find all the items that the user checked
    final selected = _selectedDurations.entries
        .where((entry) => entry.value) // Filter for true values
        .map((entry) => entry.key) // Get the name (key)
        .toList(); // Convert to a list
    
    // Print the list to the debug console
    print("Selected durations: $selected");

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RatesSetupScreen(),
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
              // --- 1. HEADER ---
              // Replaced the "TURO" Text widget
              const TuroLogoHeader(),
              const SizedBox(height: 20),

              // Replaced the progress Row widgets
              const SetupProgressHeader(
                title: "Select duration.", // <-- Updated title
                currentStep: 4, // <-- Updated step
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Replaced the Center(CircleAvatar(...))
                      const SetupScreenIcon(icon: Icons.timer_outlined), // <-- Updated icon
                      const SizedBox(height: 30),

                      // This part is specific to this screen (title/subtitle)
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
                            // Removed 'const' because TextStyle uses non-constant Colors.grey[600]
                            Text(
                              "Select below the duration you aim for the mentorship",
                              textAlign: TextAlign.center, // Added for potential wrapping
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
                      // Map over the options list and create a reusable SetupCheckboxTile for each one
                      Column(
                        children: _durationOptions.map((duration) {
                          return SetupCheckboxTile(
                            label: duration,
                            value: _selectedDurations[duration]!, // The current checked state
                            
                            // Runs when the checkbox is tapped
                            onChanged: (bool? newValue) {
                              setState(() {
                                _selectedDurations[duration] = newValue!;
                              });
                            },
                            
                            // Runs when the whole row is tapped
                            onTap: () {
                              setState(() {
                                // Toggle the value
                                _selectedDurations[duration] =
                                    !_selectedDurations[duration]!;
                              });
                            },
                          );
                        }).toList(), // Convert the map to a list
                      ),
                    ],
                  ),
                ),
              ),

              // Add a little space before the buttons
              const SizedBox(height: 20),

              // --- 3. FOOTER ---
              // Replaced the button Column
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