import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- General Setup Widgets ---

/// The "TURO" logo text, consistent on all setup screens.
/// A simple [StatelessWidget] for reusability.
class TuroLogoHeader extends StatelessWidget {
  const TuroLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "TURO",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// The header for setup screens, including the title and segmented progress bar.
/// This widget is stateless and takes the [title] and [currentStep] as parameters.
class SetupProgressHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;

  const SetupProgressHeader({
    super.key,
    required this.title,
    required this.currentStep,
    this.totalSteps = 6, // Default to 6 steps if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Progress Text (e.g., "Complete your profile" & "Step 1 of 6") ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, // The title for the current step
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Step $currentStep out of $totalSteps", // The step counter
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // --- Segmented Progress Bar ---
        Row(
          // Use List.generate to create [totalSteps] number of progress segments
          children: List.generate(totalSteps, (index) {
            return Expanded(
              child: Container(
                height: 5,
                // Add a small margin to the left of every segment except the first one
                margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
                decoration: BoxDecoration(
                  // Color logic: if the segment's index is less than the current step,
                  // color it active (green), otherwise color it inactive (grey).
                  color: index < currentStep
                      ? const Color(0xFF1B4D44) // Active color
                      : Colors.grey[300], // Inactive color
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// The footer with "Next" and "Skip" buttons.
/// Takes [onNext] and [onSkip] callback functions as parameters to handle taps.
class SetupButtonFooter extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const SetupButtonFooter({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- "Next" Button ---
        SizedBox(
          width: double.infinity, // Makes the button stretch to full width
          child: ElevatedButton(
            onPressed: onNext, // Calls the function passed into the widget
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
        
        // --- "Skip" Button ---
        TextButton(
          onPressed: onSkip, // Calls the function passed into the widget
          child: Text(
            "Skip",
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}

/// The central icon in a CircleAvatar for setup screens.
/// Takes the [icon] data as a parameter.
class SetupScreenIcon extends StatelessWidget {
  final IconData icon;
  const SetupScreenIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xFF1B4D44),
        child: Icon(icon, color: Colors.white, size: 45),
      ),
    );
  }
}

// --- Specific Widget Components ---

/// The reusable checkbox tile for selecting options (Expertise, Goals, etc.).
/// This is a custom widget to match your design, wrapping a [Checkbox] in a
/// [GestureDetector] to make the whole row tappable.
class SetupCheckboxTile extends StatelessWidget {
  final String label; // The text to display (e.g., "Software Technology")
  final bool value; // Whether the checkbox is currently checked or not
  final ValueChanged<bool?> onChanged; // Function to call when the checkbox is tapped
  final VoidCallback onTap; // Function to call when the whole row is tapped

  const SetupCheckboxTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // GestureDetector makes the entire container tappable, not just the checkbox
    return GestureDetector(
      onTap: onTap,
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
            // The label text
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            // The actual checkbox widget
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1B4D44), // Brand color
            ),
          ],
        ),
      ),
    );
  }
}

/// The reusable text field for the "Rates" screen.
/// Includes a label above the text field.
class SetupTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType; // Optional: to set the keyboard (e.g., for numbers)
  final List<TextInputFormatter>? inputFormatters; // Optional: to restrict input

  const SetupTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The label text (e.g., "Minimum Range per hour")
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        
        // The text input field
        TextField(
          controller: controller, // Links this field to a controller in the state
          keyboardType: keyboardType, // Sets the keyboard type (e.g., number pad)
          inputFormatters: inputFormatters, // Enforces formatting (e.g., numbers only)
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
            // Defines the standard border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            // Defines the border when the field is not focused
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            // Defines the border when the user taps into the field
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1B4D44), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}