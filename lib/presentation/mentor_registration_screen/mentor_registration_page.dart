import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mentor_registration_provider.dart';

// --- IMPORTS FOR ALL STEPS ---
import 'mentor_step_1_personal_details.dart';
import 'mentor_step_2_institutional_details.dart';
import 'mentor_step_3_verification.dart';
import 'mentor_step_4_credentials.dart';
import 'mentor_step_5_review.dart'; // Import the new step

class MentorRegistrationPage extends StatelessWidget {
  const MentorRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MentorRegistrationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // ---------------- HEADER SECTION ----------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2C6A64),
                        ),
                        onPressed: () {
                          if (provider.currentStep > 0) {
                            provider.previousPage();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'TURO',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Update text to "of 5"
                      Text('Step ${provider.currentStep + 1} of 5'),
                    ],
                  ),
                ),

                // ---------------- PROGRESS BAR ----------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    // Update count to 5
                    children: List.generate(5, (index) {
                      final isActive = index <= provider.currentStep;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF2C6A64)
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),

                // ---------------- BODY (PAGE VIEW) ----------------
                Expanded(
                  child: PageView(
                    controller: provider.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const MentorStep1PersonalDetails(),
                      const MentorStep2InstitutionalDetails(),
                      const MentorStep3Verification(),
                      const MentorStep4Credentials(),
                      const MentorStep5Review(), // Add the review step here
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
