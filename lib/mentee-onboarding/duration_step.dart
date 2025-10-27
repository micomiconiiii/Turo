import 'package:flutter/material.dart';

/// DurationStep lets the mentee choose a single mentorship duration.
///
/// Contract:
/// - Selection is stored locally and exposed via [selectedDuration].
/// - Parent should read [selectedDuration] and persist to the provider when
///   moving to the next step.

class DurationStep extends StatefulWidget {
  const DurationStep({super.key});

  @override
  DurationStepState createState() => DurationStepState();
}

class DurationStepState extends State<DurationStep> {
  /// Options shown to the user — keep short and friendly for readability.
  final List<String> _durations = [
    'Long-term Mentorship',
    'Short-term Mentorship',
    'Milestone-based Mentorship',
  ];
  String? _selectedDuration;

  /// Exposes the currently selected duration (or null if none).
  String? get selectedDuration => _selectedDuration;

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2C6A64);
    // Page padding to align with overall layout system
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Header block (icon + title + subtitle)
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: darkGreen,
                  child: const Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mentorship Duration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select below the duration you aim for the mentorship',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Use RadioTheme to set fillColor instead of the (sometimes)
          // deprecated activeColor on RadioListTile for Material 3.
          RadioTheme(
            data: RadioThemeData(
              fillColor: MaterialStateProperty.all(darkGreen),
            ),
            child: Column(
              children: [
                ..._durations.map(
                  (duration) => RadioListTile<String>(
                    title: Text(duration),
                    value: duration,
                    groupValue: _selectedDuration,
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value;
                      });
                    },
                  ), // return RadioListTile for each option
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ], // end column children
      ),
    ); // return Padding
  }
}
