// Import Flutter's material library and services (for text formatters)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // <-- 1. ADD THIS IMPORT for File

// Import the next screen in the flow
import 'looking_for_screen.dart';

// Import your new reusable widgets
import '../widgets/common_widgets.dart';

/// Step 5 of the profile setup: "Specify your rates."
class RatesSetupScreen extends StatefulWidget {
  // --- 2. ADD PARAMETERS from previous steps ---
  final File? profileImage;
  final List<String>? expertise;
  final List<String>? goals;
  final List<String>? durations;

  const RatesSetupScreen({
    super.key,
    // --- 3. ADD TO CONSTRUCTOR ---
    this.profileImage,
    this.expertise,
    this.goals,
    this.durations,
  });

  @override
  State<RatesSetupScreen> createState() => _RatesSetupScreenState();
}

class _RatesSetupScreenState extends State<RatesSetupScreen> {
  // Controllers to get text from text fields
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();

  /// This function runs when the widget is permanently removed from the tree.
  @override
  void dispose() {
    _minRateController.dispose();
    _maxRateController.dispose();
    super.dispose();
  }

  /// Navigates the user to the next step (LookingForScreen)
  void _goToNextStep() {
    // Get this screen's data
    final minRate = _minRateController.text;
    final maxRate = _maxRateController.text;
    // Package rates data as a Map
    final ratesData = {
      'min': minRate,
      'max': maxRate,
    };

    print("Min Rate: $minRate, Max Rate: $maxRate");

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        // --- 4. PASS ALL DATA FORWARD ---
        builder: (context) => LookingForScreen(
          profileImage: widget.profileImage, // from Step 1
          expertise: widget.expertise,       // from Step 2
          goals: widget.goals,             // from Step 3
          durations: widget.durations,     // from Step 4
          rates: ratesData,                // from Step 5 (this screen)
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
                title: "Rates",
                currentStep: 5,
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetupScreenIcon(icon: Icons.calculate_outlined),
                      const SizedBox(height: 30),
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
                      SetupTextField(
                        label: "Minimum Range per hour (PHP/hour)",
                        hint: "PHP 1000.00",
                        controller: _minRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SetupTextField(
                        label: "Maximum Range per hour (PHP/hour)",
                        hint: "PHP 10000.00",
                        controller: _maxRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
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