import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:turo_app/mentee-onboarding/provider_storage/storage.dart';

/// Final step that summarizes all captured onboarding data and asks the
/// mentee to confirm. Values are read from [MenteeOnboardingProvider].
///
/// Contract:
/// - This screen is read-only. Editing is done by navigating back.
/// - The primary action "Confirm & Finish" should trigger the final submit
///   flow (e.g., remote save + navigation). Placeholders are left as TODOs.

class ConfirmationStep extends StatelessWidget {
  const ConfirmationStep({super.key});

  /// Renders a label/value pair with consistent spacing and typography.
  Widget _buildSummaryRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read all aggregated values from the provider; nulls are normalized below
    final onboarding = context.watch<MenteeOnboardingProvider>();

    final fullName = onboarding.fullName ?? 'Not specified';
    final birthMonth = onboarding.birthMonth ?? '--';
    final birthDay = onboarding.birthDay ?? '--';
    final birthYear = onboarding.birthYear ?? '----';
    final bio = onboarding.bio ?? 'Not specified';
    final address = onboarding.address ?? 'Not specified';
    final interests = onboarding.selectedInterests.isEmpty
        ? 'Not specified'
        : onboarding.selectedInterests.join(', ');
    final goals = onboarding.selectedGoals.isEmpty
        ? 'Not specified'
        : onboarding.selectedGoals.join(', ');
    final duration = onboarding.selectedDuration ?? 'Not specified';
    final minBudget = onboarding.minBudget ?? 'N/A';
    final maxBudget = onboarding.maxBudget ?? 'N/A';

    return Scaffold(
      // Single-scrollable page with consistent horizontal padding
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                'TURO',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Row: title + step indicator
              Row(
                children: [
                  const Text(
                    'Review Your Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text('Step 5 of 5', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              // Simple 5-segment progress bar
              Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C6A64),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Header: icon + title + helper text
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF2C6A64),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Confirm Your Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please review the information you provided below.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Summary Section — mirrors the order of previous steps
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow('Full Name:', fullName),
                  _buildSummaryRow(
                    'Birthdate:',
                    '$birthMonth / $birthDay / $birthYear',
                  ),
                  _buildSummaryRow('Bio:', bio),
                  _buildSummaryRow('Address:', address),
                  _buildSummaryRow('Interests:', interests),
                  _buildSummaryRow('Goals:', goals),
                  _buildSummaryRow('Preferred Duration:', duration),
                  _buildSummaryRow('Budget Range:', '$minBudget - $maxBudget'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10403B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    debugPrint('User confirmed onboarding details.');
                    // TODO: Persist to backend (e.g., Firebase) and navigate to home.
                    // Keep this synchronous and snappy; if doing async work,
                    // show progress and handle errors gracefully.
                  },
                  child: const Text(
                    'Confirm & Finish',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFEFEFE),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Go Back or Edit',
                    style: TextStyle(
                      color: Color(0xFF2C6A64),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ); // return Scaffold
  }
}
