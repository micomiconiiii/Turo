import 'package:flutter/material.dart';
import 'goals_setup_screen.dart';

class ExpertiseSetupScreen extends StatefulWidget {
  const ExpertiseSetupScreen({super.key});

  @override
  State<ExpertiseSetupScreen> createState() => _ExpertiseSetupScreenState();
}

class _ExpertiseSetupScreenState extends State<ExpertiseSetupScreen> {
  final List<String> _expertiseOptions = [
    'Software Technology',
    'Entrepreneurship',
    'Digital Marketing',
    'App Development',
    'Business Intelligence',
    // You could even add more here, and it would still work
    // 'Data Science',
    // 'UI/UX Design',
    // 'Project Management',
  ];

  void _goToNextStep() {
    final selected = _selectedExpertise.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    print("Selected expertise: $selected");

    Navigator.push( // <-- ADD THIS NAVIGATION
      context,
      MaterialPageRoute(
        builder: (context) => const GoalsSetupScreen(),
      ),
    );
  }
  
  Map<String, bool> _selectedExpertise = {};

  @override
  void initState() {
    super.initState();
    _selectedExpertise = {
      for (var option in _expertiseOptions) option: false
    };
  }

  Widget _buildExpertiseTile(String expertise) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedExpertise[expertise] = !_selectedExpertise[expertise]!;
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
              expertise,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            Checkbox(
              value: _selectedExpertise[expertise],
              onChanged: (bool? newValue) {
                setState(() {
                  _selectedExpertise[expertise] = newValue!;
                });
              },
              activeColor: const Color(0xFF1B4D44),
            ),
          ],
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
                    "What are your expertise?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Step 2 out of 6",
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
                        color: index < 2
                            ? const Color(0xFF1B4D44)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // --- 2. MIDDLE CONTENT (Now scrollable) ---
              Expanded( // <-- WIDGET 1: ADD THIS
                child: SingleChildScrollView( // <-- WIDGET 2: ADD THIS
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF1B4D44),
                          child: const Icon(Icons.science_outlined,
                              color: Colors.white, size: 45),
                        ),
                      ),
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
                      Column(
                        children: _expertiseOptions
                            .map((expertise) => _buildExpertiseTile(expertise))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // const Spacer(), // <-- REMOVE THE SPACER, 'Expanded' replaces it.

              // --- 3. FOOTER (Stays at the bottom) ---
              const SizedBox(height: 20), // Add a little space before the buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToNextStep,
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
                    onPressed: _goToNextStep,
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