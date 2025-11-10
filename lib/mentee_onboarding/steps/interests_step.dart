import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turo_app/mentee_onboarding/providers/mentee_onboarding_provider.dart';

/// InterestsStep collects one or more areas of interest.
///
/// Highlights:
/// - Predefined list presented with checkboxes.
/// - "Other" row opens a brand-styled dialog to add custom interests.
/// - Custom interests render as auto-selected rows with a remove action.
///
/// Contract:
/// - Read [selectedInterests] to obtain all chosen interests as an immutable
///   set (predefined + custom). Parent is responsible for persisting.

class InterestsStep extends StatefulWidget {
  const InterestsStep({super.key});

  @override
  State<InterestsStep> createState() => InterestsStepState();
}

class InterestsStepState extends State<InterestsStep> {
  final List<String> _allInterests = [
    'Information Technology',
    'Business',
    'Science',
    'Arts',
    'Engineering',
    'Mathematics',
    'Health',
    'Education',
    'Social Sciences',
    'Languages',
    'Sports',
  ];
  final Set<String> _selectedInterests = {};
  final List<String> _customInterests = [];

  @override
  void initState() {
    super.initState();
    // Restore state from provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MenteeOnboardingProvider>(
        context,
        listen: false,
      );

      // Get all selected interests from provider
      final providerInterests = provider.selectedInterests;

      if (providerInterests.isNotEmpty) {
        setState(() {
          // Separate predefined interests from custom interests
          for (final interest in providerInterests) {
            if (_allInterests.contains(interest)) {
              // This is a predefined interest
              _selectedInterests.add(interest);
            } else {
              // This is a custom interest
              _customInterests.add(interest);
            }
          }
        });
      }
    });
  }

  /// Returns an immutable union of predefined selections and custom entries.
  Set<String> get selectedInterests {
    // Combine predefined and custom interests
    final combined = <String>{..._selectedInterests, ..._customInterests};
    return Set.unmodifiable(combined);
  }

  /// Opens an input dialog for adding a custom interest.
  /// Custom entries appear as pre-selected rows and can be removed.
  void _showAddCustomInterestDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Other Interest',
          style: TextStyle(
            color: Color(0xFF10403B),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your interest',
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
              if (custom.isNotEmpty && !_customInterests.contains(custom)) {
                setState(() {
                  _customInterests.add(custom);
                  // Auto-select the custom interest (it's already included in selectedInterests getter)
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
    // Wrap content with horizontal padding to align with page margins
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Header block with icon, title, and helper text
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: darkGreen,
                  child: const Icon(
                    Icons.science_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Interests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tick the boxes below that match your interests.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Interests list expands within parent
          Expanded(
            child: ListView.builder(
              itemCount:
                  _allInterests.length +
                  _customInterests.length +
                  1, // +1 for "Other" item
              itemBuilder: (context, index) {
                // Show predefined interests first
                if (index < _allInterests.length) {
                  final interest = _allInterests[index];
                  return CheckboxListTile(
                    title: Text(interest),
                    value: _selectedInterests.contains(interest),
                    activeColor: darkGreen,
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                  ); // return CheckboxListTile for a predefined option
                } else if (index <
                    _allInterests.length + _customInterests.length) {
                  // Custom interests - auto-selected, no checkbox, just remove button
                  final customIndex = index - _allInterests.length;
                  final customInterest = _customInterests[customIndex];
                  return ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2C6A64),
                    ),
                    title: Text(customInterest),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.grey[600],
                      tooltip: 'Remove',
                      onPressed: () {
                        setState(() {
                          _customInterests.removeAt(customIndex);
                        });
                      },
                    ),
                  ); // return ListTile for an auto-selected custom item
                } else {
                  // "Other" option with plus icon at the bottom. Padding and
                  // spacing align the icon with the checkbox column visually.
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
                    onTap: _showAddCustomInterestDialog,
                  ); // return ListTile to trigger add dialog
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
