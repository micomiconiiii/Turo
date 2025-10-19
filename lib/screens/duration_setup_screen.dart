import 'package:flutter/material.dart';
import 'rates_setup_screen.dart';

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

  // 2. Map to store the checked state of each option
  Map<String, bool> _selectedDurations = {};

  @override
  void initState() {
    super.initState();
    // 3. Initialize the map
    _selectedDurations = {
      for (var option in _durationOptions) option: false
    };
  }

  // 4. Helper method to build each custom checkbox tile
  Widget _buildDurationTile(String duration) {
    return GestureDetector(
      onTap: () {
        // Toggle the state when the row is tapped
        setState(() {
          _selectedDurations[duration] = !_selectedDurations[duration]!;
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
              duration,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            Checkbox(
              value: _selectedDurations[duration],
              onChanged: (bool? newValue) {
                setState(() {
                  _selectedDurations[duration] = newValue!;
                });
              },
              activeColor: const Color(0xFF1B4D44), // Your brand color
            ),
          ],
        ),
      ),
    );
  }

  // Function to navigate to the next step
  void _goToNextStep() {
    final selected = _selectedDurations.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    print("Selected durations: $selected");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RatesSetupScreen(), // <-- CHANGE TO THIS
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
                    "Select duration.", // <-- UPDATED
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Step 4 out of 6", // <-- UPDATED
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
                        // Fill 4 segments (index 0, 1, 2, 3)
                        color: index < 4 // <-- UPDATED
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
                          // This icon matches your design
                          child: const Icon(Icons.timer_outlined, // <-- UPDATED ICON
                              color: Colors.white, size: 45),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Mentorship Duration", // <-- UPDATED
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Select below the duration you aim for the mentorship", // <-- UPDATED
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
                        children: _durationOptions
                            .map((duration) => _buildDurationTile(duration))
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
                      onPressed: _goToNextStep, // <-- Calls navigation function
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
                    onPressed: _goToNextStep, // <-- Calls navigation function
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