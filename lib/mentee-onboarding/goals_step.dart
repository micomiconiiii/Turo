import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider_storage/storage.dart';

/// GoalsStep collects one or more mentorship goals.
///
/// Highlights:
/// - Predefined list presented with checkboxes.
/// - "Other" row opens a brand-styled dialog to add custom goals.
/// - Custom goals appear as auto-selected rows with a remove action (no checkbox).
///
/// Contract:
/// - Read [selectedGoals] to obtain a combined, immutable set of all chosen
///   goals (predefined + custom). Parent is responsible for persisting.

class GoalsStep extends StatefulWidget {
  const GoalsStep({super.key});

  @override
  State<GoalsStep> createState() => GoalsStepState();
}

class GoalsStepState extends State<GoalsStep> {
  final List<String> _allGoals = [
    'Career Development',
    'Business Consultation',
    'Academics',
    'Personal Growth',
  ];

  final Set<String> _selectedGoals = {};
  final List<String> _customGoals = [];

  @override
  void initState() {
    super.initState();
    // Restore state from provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MenteeOnboardingProvider>(
        context,
        listen: false,
      );

      // Get all selected goals from provider
      final providerGoals = provider.selectedGoals;

      if (providerGoals.isNotEmpty) {
        setState(() {
          // Separate predefined goals from custom goals
          for (final goal in providerGoals) {
            if (_allGoals.contains(goal)) {
              // This is a predefined goal
              _selectedGoals.add(goal);
            } else {
              // This is a custom goal
              _customGoals.add(goal);
            }
          }
        });
      }
    });
  }

  /// Returns an immutable union of predefined selections and custom entries.
  Set<String> get selectedGoals {
    // Combine predefined and custom goals
    final combined = <String>{..._selectedGoals, ..._customGoals};
    return Set.unmodifiable(combined);
  }

  /// Opens an input dialog for adding a custom goal.
  /// The newly added goal is displayed as pre-selected (no checkbox) and can
  /// be removed from the list.
  void _showAddCustomGoalDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Other Goal',
          style: TextStyle(
            color: Color(0xFF10403B),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your mentorship goal',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C6A64)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C6A64), width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2C6A64),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              final custom = controller.text.trim();
              if (custom.isNotEmpty && !_customGoals.contains(custom)) {
                setState(() {
                  _customGoals.add(custom);
                  // Auto-select the custom goal (it's already included in selectedGoals getter)
                });
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10403B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2C6A64);
    // Outer padding to match screen margins
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Header: icon + title + helper text
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: darkGreen,
                  child: const Icon(
                    Icons.person_pin_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mentorship Goals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the goals you want to achieve through mentorship.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount:
                  _allGoals.length +
                  _customGoals.length +
                  1, // +1 for "Other" item
              itemBuilder: (context, index) {
                // Show predefined goals first
                if (index < _allGoals.length) {
                  final goal = _allGoals[index];
                  return CheckboxListTile(
                    title: Text(goal),
                    value: _selectedGoals.contains(goal),
                    activeColor: darkGreen,
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedGoals.add(goal);
                        } else {
                          _selectedGoals.remove(goal);
                        }
                      });
                    },
                  ); // return CheckboxListTile for predefined
                } else if (index < _allGoals.length + _customGoals.length) {
                  // Custom goals - auto-selected, no checkbox, just remove button
                  final customIndex = index - _allGoals.length;
                  final customGoal = _customGoals[customIndex];
                  return ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2C6A64),
                    ),
                    title: Text(customGoal),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.grey[600],
                      tooltip: 'Remove',
                      onPressed: () {
                        setState(() {
                          _customGoals.removeAt(customIndex);
                        });
                      },
                    ),
                  ); // return ListTile for custom goal row
                } else {
                  // "Other" option with plus icon at the bottom.
                  // The plus icon is aligned with the checkbox column via
                  // content padding and spacing to maintain visual rhythm.
                  return ListTile(
                    contentPadding: const EdgeInsets.only(
                      left: 16.0,
                      right: 31.0,
                    ),
                    title: Row(
                      children: [
                        const Expanded(child: Text('Other')),
                        const SizedBox(width: 32),
                        const Icon(
                          Icons.add_box_rounded,
                          color: Colors.black54,
                          size: 26,
                        ),
                      ],
                    ),
                    onTap: _showAddCustomGoalDialog,
                  ); // return ListTile for "Other" add flow
                }
              },
            ),
          ),
          const SizedBox(height: 8),
        ], // end column children
      ),
    ); // return Padding
  }
}
