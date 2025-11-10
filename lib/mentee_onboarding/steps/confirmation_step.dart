import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:turo_app/mentee_onboarding/providers/mentee_onboarding_provider.dart';
import 'package:turo_app/services/database_service.dart';
import 'package:turo_app/services/storage_service.dart';
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

  @override
  Widget build(BuildContext context) {
    // Read all aggregated values from the provider
    final onboarding = context.watch<MenteeOnboardingProvider>();

    final fullName = onboarding.fullName ?? 'Not specified';
    final bio = onboarding.bio ?? 'No bio provided';
    final interests = onboarding.selectedInterests.isEmpty
        ? 'Not specified'
        : onboarding.selectedInterests.join(', ');
    final goals = onboarding.selectedGoals.isEmpty
        ? 'Not specified'
        : onboarding.selectedGoals.join(', ');
    final duration = onboarding.selectedDuration ?? 'Not specified';
    final minBudget = onboarding.minBudget ?? '0';
    final maxBudget = onboarding.maxBudget ?? '0';

    // Format birthdate
    final birthMonth = int.tryParse(onboarding.birthMonth ?? '1') ?? 1;
    final birthDay = int.tryParse(onboarding.birthDay ?? '1') ?? 1;
    final birthYear = int.tryParse(onboarding.birthYear ?? '2000') ?? 2000;
    final birthdate = DateTime(birthYear, birthMonth, birthDay);
    final formattedBirthdate =
        '${birthdate.month.toString().padLeft(2, '0')}/${birthdate.day.toString().padLeft(2, '0')}/${birthdate.year}';

    // Format full address
    final addressParts = [
      if (onboarding.addressDetails['unitBldg']?.isNotEmpty ?? false)
        onboarding.addressDetails['unitBldg'],
      if (onboarding.addressDetails['street']?.isNotEmpty ?? false)
        onboarding.addressDetails['street'],
      if (onboarding.addressDetails['barangay']?.isNotEmpty ?? false)
        'Brgy. ${onboarding.addressDetails['barangay']}',
      if (onboarding.addressDetails['cityMunicipality']?.isNotEmpty ?? false)
        onboarding.addressDetails['cityMunicipality'],
      if (onboarding.addressDetails['province']?.isNotEmpty ?? false)
        onboarding.addressDetails['province'],
      if (onboarding.addressDetails['zip']?.isNotEmpty ?? false)
        onboarding.addressDetails['zip'],
    ];
    final fullAddress = addressParts.isEmpty
        ? 'Not specified'
        : addressParts.join(', ');

    // Check if user has selected a profile picture (before upload)
    final hasProfilePicture =
        onboarding.profilePictureFile != null ||
        onboarding.profilePictureBytes != null;

    return Scaffold(
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
              Row(
                children: [
                  const Text(
                    'Review Your Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text('Step 6 of 6', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
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
              Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.18),
                surfaceTintColor: Colors.white,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.black.withOpacity(0.14)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: hasProfilePicture
                                ? (kIsWeb &&
                                          onboarding.profilePictureBytes != null
                                      ? MemoryImage(
                                              onboarding.profilePictureBytes!,
                                            )
                                            as ImageProvider
                                      : (onboarding.profilePictureFile != null
                                            ? FileImage(
                                                onboarding.profilePictureFile!,
                                              )
                                            : null))
                                : null,
                            child: !hasProfilePicture
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.cake_outlined,
                          color: Color(0xFF2C6A64),
                        ),
                        title: const Text('Birthdate'),
                        trailing: Text(
                          formattedBirthdate,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF2C6A64),
                        ),
                        title: const Text('Address'),
                        subtitle: Text(
                          fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.lightbulb_outlined,
                          color: Color(0xFF2C6A64),
                        ),
                        title: const Text('Interests'),
                        subtitle: Text(
                          interests,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.flag_outlined,
                          color: Color(0xFF2C6A64),
                        ),
                        title: const Text('Goals'),
                        subtitle: Text(
                          goals,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.timelapse_outlined,
                          color: Color(0xFF2C6A64),
                        ),
                        title: const Text('Preferred Duration'),
                        trailing: Text(
                          duration,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.wallet_outlined,
                          color: Color(0xFF2C6A64),
                        ),
                        title: const Text('Budget Range'),
                        trailing: Text(
                          'PHP $minBudget - $maxBudget',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

                            // Capture context-dependent values BEFORE async operations
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            // Upload profile picture if selected (before creating profile)
                            String? profilePictureUrl;
                            if (provider.profilePictureFile != null ||
                                provider.profilePictureBytes != null) {
                              try {
                                final storage = StorageService();
                                final path =
                                    'profile_pictures/$userId/profile.jpg';

                                if (kIsWeb &&
                                    provider.profilePictureBytes != null) {
                                  // Set proper content type for web uploads
                                  final metadata = SettableMetadata(
                                    contentType: 'image/jpeg',
                                  );
                                  profilePictureUrl = await storage.uploadBytes(
                                    path,
                                    provider.profilePictureBytes!,
                                    metadata: metadata,
                                  );
                                } else if (provider.profilePictureFile !=
                                    null) {
                                  profilePictureUrl = await storage.uploadFile(
                                    path,
                                    provider.profilePictureFile!,
                                  );
                                }

                                // Store URL in provider for display
                                // ignore: use_build_context_synchronously
                                if (profilePictureUrl != null) {
                                  provider.setProfilePictureUrl(
                                    profilePictureUrl,
                                  );
                                }
                              } catch (uploadError) {
                                debugPrint(
                                  'Failed to upload profile picture: $uploadError',
                                );
                                // Continue anyway - profile picture is optional
                              }
                            }

                            if (!mounted) return;

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
                              userId: userId,
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
              const SizedBox(height: 8),
              TextButton(
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
            ],
          ),
        ),
      ),
    ); // return Scaffold
  }
}
