// Import Flutter's material library
import 'package:flutter/material.dart';

// Import MyProfileScreen to check its type in popUntil
import 'my_profile_screen.dart';

// Import your reusable widgets
import '../widgets/common_widgets.dart';

/// Step 6 of the profile setup: "Who are you looking for?"
class LookingForScreen extends StatefulWidget {
  const LookingForScreen({super.key});

  @override
  State<LookingForScreen> createState() => _LookingForScreenState();
}

class _LookingForScreenState extends State<LookingForScreen> {
  // List of all available options
  final List<String> _lookingForOptions = [
    'Students',
    'Freelance Developers',
    'Startups',
  ];

  // Map to store the checked state
  Map<String, bool> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _selectedOptions = {
      for (var option in _lookingForOptions) option: false
    };
  }

  /// Function to FINISH setup and go BACK to the MyProfileScreen.
  void _finishSetup() {
    final selected = _selectedOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print("Looking for: $selected");

    // --- Pop back UNTIL MyProfileScreen ---
    // This removes all screens from the stack until it finds
    // the route whose settings name matches MyProfileScreen.
    // If MyProfileScreen isn't found (which shouldn't happen here),
    // it might pop back further than expected.
    // A more robust way involves named routes or checking route types.

    // Let's try popping until the first route (simplest)
    // This assumes MyProfileScreen was pushed directly onto the initial route.
    // If MyProfileScreen was pushed on top of other screens (like MainScreen),
    // this might pop too far.

    // A slightly safer way without named routes: Pop until a route
    // whose TYPE is MyProfileScreen is encountered.
    // NOTE: This requires MyProfileScreen to be imported.
    Navigator.popUntil(context, (route) {
      // Check if the route is the MyProfileScreen OR if it's the very first route
      // This handles cases where MyProfileScreen might be the initial route.
      return route.settings.name == '/myprofile' || route is MaterialPageRoute<dynamic> && route.builder(context) is MyProfileScreen || route.isFirst;
       // For a more robust solution, consider named routes:
       // return route.settings.name == MyProfileScreen.routeName;
       // Or pop a fixed number of times if you know exactly how many screens were pushed:
       // int count = 0;
       // Navigator.popUntil(context, (route) => count++ == 6); // Pop 6 times
    });


    // --- Alternative (Simpler but potentially fragile): Pop 6 times ---
    // If you are SURE exactly 6 screens were pushed on top of MyProfileScreen,
    // you could just pop 6 times. Less flexible if the flow changes.
    /*
    int popCount = 0;
    Navigator.popUntil(context, (route) {
      return popCount++ >= 6; // Pop exactly 6 times
    });
    */
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
              // --- HEADER ---
              const TuroLogoHeader(),
              const SizedBox(height: 20),
              const SetupProgressHeader(
                title: "Who are you looking for?",
                currentStep: 6,
              ),
              const SizedBox(height: 40),

              // --- MIDDLE CONTENT ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SetupScreenIcon(icon: Icons.calculate_outlined),
                      const SizedBox(height: 30),
                      Center(/* ... Title/Subtitle ... */),
                      const SizedBox(height: 30),
                      // --- Checkbox List ---
                      Column(
                        children: _lookingForOptions.map((option) {
                          return SetupCheckboxTile(
                            label: option,
                            value: _selectedOptions[option]!,
                            onChanged: (bool? newValue) {
                              setState(() { _selectedOptions[option] = newValue!; });
                            },
                            onTap: () {
                              setState(() { _selectedOptions[option] = !_selectedOptions[option]!; });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- FOOTER ---
              SetupButtonFooter(
                onNext: _finishSetup,
                onSkip: _finishSetup,
              ),
            ],
          ),
        ),
      ),
    );
  }
} // Added closing brace