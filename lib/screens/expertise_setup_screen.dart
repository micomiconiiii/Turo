// Import Flutter's material library
import 'package:flutter/material.dart';

// Import the next screen in the flow
import 'goals_setup_screen.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 2 of the profile setup: "What are your expertise?"
/// This is a StatefulWidget because it needs to store the state
/// of the checkboxes.
class ExpertiseSetupScreen extends StatefulWidget {
  const ExpertiseSetupScreen({super.key});

  @override
  State<ExpertiseSetupScreen> createState() => _ExpertiseSetupScreenState();
}

class _ExpertiseSetupScreenState extends State<ExpertiseSetupScreen> {
  // 1. List of all available expertise options
  final List<String> _expertiseOptions = [
    'Software Technology',
    'Entrepreneurship',
    'Digital Marketing',
    'App Development',
    'Business Intelligence',
  ];

  // 2. Map to store the checked state (true/false) of each option
  Map<String, bool> _selectedExpertise = {};

  /// This function runs once when the widget is first created.
  @override
  void initState() {
    super.initState();
    // 3. Initialize the map, setting all options to 'false' (unchecked)
    _selectedExpertise = {
      for (var option in _expertiseOptions) option: false
    };
  }

  /// Navigates the user to the next step (GoalsSetupScreen)
  void _goToNextStep() {
    // First, find all the items that the user checked (where value is true)
    final selected = _selectedExpertise.entries
        .where((entry) => entry.value) // Filter for true values
        .map((entry) => entry.key) // Get the name (key)
        .toList(); // Convert to a list
    
    // Print the list to the debug console
    print("Selected expertise: $selected");

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalsSetupScreen(),
      ),
    );
  }
  
  // 4. We no longer need the _buildExpertiseTile method, 
  //    as this logic is now inside `SetupCheckboxTile` in common_widgets.dart

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
              // Replaced the "TURO" Text widget with your common widget
              const TuroLogoHeader(),
              const SizedBox(height: 20),

              // Replaced the progress Row widgets with your common header
              const SetupProgressHeader(
                title: "What are your expertise?",
                currentStep: 2, // This is Step 2
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Replaced the Center(CircleAvatar(...)) with your common icon widget
                      const SetupScreenIcon(icon: Icons.science_outlined),
                      const SizedBox(height: 30),

                      // This part is specific to this screen (title/subtitle)
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
                            // Removed 'const' because TextStyle uses non-constant Colors.grey[600]
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
                      // We map over our list of options and build a
                      // SetupCheckboxTile for each one.
                      Column(
                        children: _expertiseOptions.map((expertise) {
                          return SetupCheckboxTile(
                            label: expertise,
                            value: _selectedExpertise[expertise]!, // The current checked state
                            
                            // This runs when the user taps the checkbox directly
                            onChanged: (bool? newValue) {
                              setState(() {
                                _selectedExpertise[expertise] = newValue!;
                              });
                            },
                            
                            // This runs when the user taps the whole row
                            onTap: () {
                              setState(() {
                                // Toggle the value
                                _selectedExpertise[expertise] =
                                    !_selectedExpertise[expertise]!;
                              });
                            },
                          );
                        }).toList(), // Convert the mapped items into a list of widgets
                      ),
                    ],
                  ),
                ),
              ),

              // Add a little space before the buttons
              const SizedBox(height: 20), 

              // --- 3. FOOTER ---
              // Replaced the button Column with your common footer widget
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