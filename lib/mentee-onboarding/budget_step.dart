import 'package:flutter/material.dart';

/// BudgetStep collects the mentee's preferred budget range.
///
/// Contract:
/// - Call [validateAndSave] before progressing to the next step.
///   Returns true when both fields are valid.
/// - Use the getters [minBudget] and [maxBudget] to read the sanitized values
///   (null if empty). These expose raw strings so the parent can format/store
///   them consistently.
/// - This widget does not persist values by itself; the parent stepper/page
///   should read the values and write them to the provider.

class BudgetStep extends StatefulWidget {
  const BudgetStep({super.key});

  @override
  State<BudgetStep> createState() => BudgetStepState();
}

class BudgetStepState extends State<BudgetStep> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();

  /// Validates the form and triggers onSaved for fields if valid.
  /// Returns true when all validators pass.
  bool validateAndSave() {
    final form = _formKey.currentState;
    // If this widget hasn't built a form yet, treat as valid (no blockers)
    if (form == null) return true;
    final valid = form.validate();
    if (valid) {
      form.save();
    }
    return valid;
  }

  /// Sanitized minimum budget string or null when empty.
  String? get minBudget {
    final value = _minBudgetController.text.trim();
    return value.isEmpty ? null : value;
  }

  /// Sanitized maximum budget string or null when empty.
  String? get maxBudget {
    final value = _maxBudgetController.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Top-level container that constrains horizontal padding
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      // Form groups both fields for validation
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + title + subtitle
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF2C6A64),
                    child: const Icon(
                      Icons.calculate_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Budget',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter a range of preferred budget for the mentorship',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Minimum input
            const Text('Minimum Range'),
            TextFormField(
              controller: _minBudgetController,
              keyboardType: TextInputType.number,
              // Validate presence and positivity; numeric parsing tolerates decimals
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Budget cannot be empty.';
                final num? min = num.tryParse(v);
                if (min == null || min <= 0) {
                  return 'Enter a valid positive number.';
                }
                return null;
              },
              decoration: const InputDecoration(hintText: 'PHP 1000.00'),
            ),
            const SizedBox(height: 20),
            // Maximum input
            const Text('Maximum Range'),
            TextFormField(
              controller: _maxBudgetController,
              keyboardType: TextInputType.number,
              // Validate presence, positivity, and min <= max when both provided
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Budget cannot be empty.';
                final num? max = num.tryParse(v);
                final num? min = num.tryParse(_minBudgetController.text.trim());
                if (max == null || max <= 0) {
                  return 'Enter a valid positive number.';
                }
                if (min != null && max < min) {
                  return 'Maximum budget must be greater than or equal to minimum budget.';
                }
                return null;
              },
              decoration: const InputDecoration(hintText: 'PHP 10000.00'),
            ),
            const SizedBox(height: 24),
            // Nothing to render below; parent page renders navigation actions
          ],
        ),
      ),
    ); // return Padding
  }
}
