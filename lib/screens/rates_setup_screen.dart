import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To use number input formatting
import 'looking_for_screen.dart';

class RatesSetupScreen extends StatefulWidget {
  const RatesSetupScreen({super.key});

  @override
  State<RatesSetupScreen> createState() => _RatesSetupScreenState();
}

class _RatesSetupScreenState extends State<RatesSetupScreen> {
  // 1. Controllers to get text from text fields
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();

  @override
  void dispose() {
    // 2. Important: Dispose controllers when the widget is removed
    _minRateController.dispose();
    _maxRateController.dispose();
    super.dispose();
  }

  // 3. Function to navigate to the next step
  void _goToNextStep() {
    final minRate = _minRateController.text;
    final maxRate = _maxRateController.text;
    print("Min Rate: $minRate, Max Rate: $maxRate");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LookingForScreen(), // <-- CHANGE TO THIS
      ),
    );
  }

  // Helper widget to build the text field labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    );
  }

  // Helper widget to build the text fields
  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      // 4. Set keyboard type to numbers and dots
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        // Allow only numbers and a single dot
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1B4D44), width: 2),
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
              // --- 1. HEADER (Stays at the top) ---
              const Text(
                "TURO",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rates", // <-- UPDATED
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Step 5 out of 6", // <-- UPDATED
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
                      decoration: BoxDecoration(
                        // Fill 5 segments
                        color: index < 5 // <-- UPDATED
                            ? const Color(0xFF1B4D44)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Scrollable) ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF1B4D44),
                          // This icon matches your design
                          child: const Icon(Icons.calculate_outlined, // <-- UPDATED ICON
                              color: Colors.white,
                              size: 45),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Specify your rates.", // <-- UPDATED
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "What are your rates?", // <-- UPDATED
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // 5. Text Fields for Rates
                      _buildLabel("Minimum Range per hour (PHP/hour)"),
                      const SizedBox(height: 10),
                      _buildTextField("PHP 1000.00", _minRateController),
                      const SizedBox(height: 20),
                      _buildLabel("Maximum Range per hour (PHP/hour)"),
                      const SizedBox(height: 10),
                      _buildTextField("PHP 10000.00", _maxRateController),
                    ],
                  ),
                ),
              ),

              // --- 3. FOOTER (Stays at the bottom) ---
              const SizedBox(height: 20),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToNextStep, // Calls navigation function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4D44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _goToNextStep, // Calls navigation function
                    child: Text(
                      "Skip",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}