import 'package:flutter/material.dart';
import 'main_screen.dart';

class LookingForScreen extends StatefulWidget {
  const LookingForScreen({super.key});

  @override
  State<LookingForScreen> createState() => _LookingForScreenState();
}

class _LookingForScreenState extends State<LookingForScreen> {
  // 1. List of all available options
  final List<String> _lookingForOptions = [
    'Students',
    'Freelance Developers',
    'Startups',
  ];

  // 2. Map to store the checked state of each option
  Map<String, bool> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    // 3. Initialize the map
    _selectedOptions = {
      for (var option in _lookingForOptions) option: false
    };
  }

  // 4. Helper method to build each custom checkbox tile
  Widget _buildLookingForTile(String option) {
    return GestureDetector(
      onTap: () {
        // Toggle the state when the row is tapped
        setState(() {
          _selectedOptions[option] = !_selectedOptions[option]!;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            Checkbox(
              value: _selectedOptions[option],
              onChanged: (bool? newValue) {
                setState(() {
                  _selectedOptions[option] = newValue!;
                });
              },
              activeColor: const Color(0xFF1B4D44), // Your brand color
            ),
          ],
        ),
      ),
    );
  }

  // 5. Function to FINISH setup and go to the app's home screen
  void _finishSetup() {
    final selected = _selectedOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    print("Looking for: $selected");

    // This is the important part for the LAST screen:
    // We navigate to the home screen and REMOVE all previous routes (the setup screens)
    // so the user can't press "back" and return to the setup flow.

    // TODO: Replace 'PlaceholderHomeScreen()' with your actual home/dashboard screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(), // <-- CHANGE TO THIS
      ),
      (Route<dynamic> route) => false,
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
                    "Who are you looking for?", // <-- UPDATED
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Step 6 out of 6", // <-- UPDATED
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
                        // Fill all 6 segments
                        color: index < 6 // <-- UPDATED (All filled)
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
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF1B4D44),
                          // Following your image, using the calculator icon again
                          child: const Icon(Icons.calculate_outlined, // <-- ICON
                              color: Colors.white,
                              size: 45),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "I am looking for...", // <-- UPDATED
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Tick the boxes below", // <-- UPDATED
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        // Use the new options and builder function
                        children: _lookingForOptions
                            .map((option) => _buildLookingForTile(option))
                            .toList(),
                      ),
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
                      onPressed: _finishSetup, // <-- Calls FINISH function
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
                    onPressed: _finishSetup, // <-- Calls FINISH function
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

