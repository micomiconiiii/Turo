// Import Flutter's material library and services (for text formatters)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import the next screen in the flow
import 'looking_for_screen.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 5 of the profile setup: "Specify your rates."
/// This is a StatefulWidget because it uses TextEditingControllers
/// to manage the state of the input fields.
class RatesSetupScreen extends StatefulWidget {
  const RatesSetupScreen({super.key});

  @override
  State<RatesSetupScreen> createState() => _RatesSetupScreenState();
}

class _RatesSetupScreenState extends State<RatesSetupScreen> {
  // 1. Controllers to get text from text fields
  // These controllers are used by the SetupTextField widget.
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();

  /// This function runs when the widget is permanently removed from the tree.
  /// It's important to dispose controllers to free up resources.
  @override
  void dispose() {
    _minRateController.dispose();
    _maxRateController.dispose();
    super.dispose();
  }

  /// Navigates the user to the next step (LookingForScreen)
  void _goToNextStep() {
    // Get the text entered by the user from the controllers
    final minRate = _minRateController.text;
    final maxRate = _maxRateController.text;

    // Print the values to the debug console
    print("Min Rate: $minRate, Max Rate: $maxRate");

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LookingForScreen(),
      ),
    );
  }

  // 4. We no longer need the _buildLabel and _buildTextField helper methods,
  //    as this logic is now inside `SetupTextField`.

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
                title: "Rates", // <-- Updated title
                currentStep: 5, // <-- Updated step
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Keep alignment
                    children: [
                      // Replaced the Center(CircleAvatar(...))
                      const SetupScreenIcon(icon: Icons.calculate_outlined), // <-- Updated icon
                      const SizedBox(height: 30),

                      // This part is specific to this screen (title/subtitle)
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Specify your rates.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Removed 'const' because TextStyle uses non-constant Colors.grey[600]
                            Text(
                              "What are your rates?",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Text Fields for Rates ---
                      // Replaced the custom helper methods with the reusable SetupTextField widget
                      SetupTextField(
                        label: "Minimum Range per hour (PHP/hour)",
                        hint: "PHP 1000.00",
                        controller: _minRateController, // Pass the controller
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), // Set keyboard
                        inputFormatters: [ // Enforce number format
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SetupTextField(
                        label: "Maximum Range per hour (PHP/hour)",
                        hint: "PHP 10000.00",
                        controller: _maxRateController, // Pass the controller
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), // Set keyboard
                        inputFormatters: [ // Enforce number format
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
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