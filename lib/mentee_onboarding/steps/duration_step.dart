import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turo_app/mentee_onboarding/providers/mentee_onboarding_provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Restore state from provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MenteeOnboardingProvider>(
        context,
        listen: false,
      );

      // Restore selected duration from provider
      if (provider.selectedDuration != null) {
        setState(() {
          _selectedDuration = provider.selectedDuration;
        });
      }
    });
  }

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
          // Use ListTile with manual radio icon to avoid deprecation warnings
          Column(
            children: _durations.map((duration) {
              final isSelected = _selectedDuration == duration;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? darkGreen : Colors.grey,
                ),
                title: Text(duration),
                onTap: () {
                  setState(() {
                    _selectedDuration = duration;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ], // end column children
      ),
    ); // return Padding
  }
}
