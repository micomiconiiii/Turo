import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turo_app/mentee-onboarding/provider_storage/storage.dart';
import 'package:turo_app/services/database_service.dart';
import 'package:turo_app/models/user_profile_model.dart';
import 'package:turo_app/models/mentee_profile_model.dart';

/// Final step that summarizes all captured onboarding data and asks the
/// mentee to confirm. Values are read from [MenteeOnboardingProvider].
///
/// Contract:
/// - This screen is read-only. Editing is done by navigating back.
/// - The primary action "Confirm & Finish" triggers saving to Firestore.

class ConfirmationStep extends StatefulWidget {
  const ConfirmationStep({super.key});

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> {
  bool _isSaving = false;

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
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() {
                            _isSaving = true;
                          });

                          try {
                            // Get authenticated user ID
                            final currentUser =
                                FirebaseAuth.instance.currentUser;
                            if (currentUser == null) {
                              throw Exception(
                                'No authenticated user. Please enable Anonymous '
                                'Authentication in Firebase Console.',
                              );
                            }
                            final userId = currentUser.uid;

                            // Get data from provider
                            final provider = context
                                .read<MenteeOnboardingProvider>();

                            // Parse birthdate from provider fields
                            final birthMonth =
                                int.tryParse(provider.birthMonth ?? '1') ?? 1;
                            final birthDay =
                                int.tryParse(provider.birthDay ?? '1') ?? 1;
                            final birthYear =
                                int.tryParse(provider.birthYear ?? '2000') ??
                                2000;
                            final birthdate = DateTime(
                              birthYear,
                              birthMonth,
                              birthDay,
                            );

                            // Create UserProfileModel instance
                            final userProfile = UserProfileModel(
                              fullName: provider.fullName ?? '',
                              birthdate: birthdate,
                              bio: provider.bio ?? '',
                              addressUnitBldg:
                                  provider.addressDetails['unitBldg'] ?? '',
                              addressStreet:
                                  provider.addressDetails['street'] ?? '',
                              addressBarangay:
                                  provider.addressDetails['barangay'] ?? '',
                              addressCity:
                                  provider.addressDetails['cityMunicipality'] ??
                                  '',
                              addressProvince:
                                  provider.addressDetails['province'] ?? '',
                              addressZipCode:
                                  provider.addressDetails['zip'] ?? '',
                            );

                            // Parse budget values
                            final minBudget =
                                double.tryParse(provider.minBudget ?? '0') ??
                                0.0;
                            final maxBudget =
                                double.tryParse(provider.maxBudget ?? '0') ??
                                0.0;

                            // Create MenteeProfileModel instance
                            final menteeProfile = MenteeProfileModel(
                              userId: userId,
                              interests: provider.selectedInterests.toList(),
                              goals: provider.selectedGoals.toList(),
                              selectedDuration: provider.selectedDuration ?? '',
                              minBudget: minBudget,
                              maxBudget: maxBudget,
                            );

                            // Instantiate DatabaseService
                            final databaseService = DatabaseService();

                            // Capture context-dependent values BEFORE async operation
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            // Save to Firestore using batched write
                            await databaseService.createMenteeOnboardingData(
                              userId: userId,
                              profile: userProfile,
                              menteeProfile: menteeProfile,
                            );

                            // Check mounted state after async gap
                            if (!mounted) return;

                            // Show success feedback
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Onboarding saved successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );

                            debugPrint('Onboarding saved for user: $userId');

                            // TODO: Navigate to home screen when route is created
                            // if (mounted) {
                            //   Navigator.of(context).pushReplacementNamed('/home');
                            // }
                          } catch (e) {
                            // Check mounted state after async gap
                            if (!mounted) return;

                            // Show error feedback
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );

                            debugPrint('Error saving onboarding: $e');
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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
