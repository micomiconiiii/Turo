// Material widgets and theming.
import 'package:flutter/material.dart';
// Provider access helpers for reading/watching ChangeNotifiers.
import 'package:provider/provider.dart';
// Individual step widgets with their State classes for keys/access.
import 'package:turo_app/mentee-onboarding/budget_step.dart'
    show BudgetStep, BudgetStepState;
// Confirmation page imported with alias to avoid name collision.
import 'package:turo_app/mentee-onboarding/confirmation_step.dart'
    as confirmation_step;
import 'package:turo_app/mentee-onboarding/duration_step.dart'
    show DurationStep, DurationStepState;
import 'package:turo_app/mentee-onboarding/goals_step.dart'
    show GoalsStep, GoalsStepState;
import 'package:turo_app/mentee-onboarding/interests_step.dart'
    show InterestsStep, InterestsStepState;
import 'package:turo_app/mentee-onboarding/personal_info_step.dart'
    show PersonalInfoStep, PersonalInfoStepState;
// Global onboarding provider to persist step data.
import 'package:turo_app/mentee-onboarding/provider_storage/storage.dart';

/// A stepper-style onboarding page that hosts multiple step widgets and
/// controls navigation between them.
class MenteeOnboardingPage extends StatefulWidget {
  const MenteeOnboardingPage({super.key});

  @override
  State<MenteeOnboardingPage> createState() => _MenteeOnboardingPageState();
}

class _MenteeOnboardingPageState extends State<MenteeOnboardingPage> {
  // Keys to access internal state of each step for validation/data reads.
  final _personalInfoKey = GlobalKey<PersonalInfoStepState>();
  final _interestsKey = GlobalKey<InterestsStepState>();
  final _goalsKey = GlobalKey<GoalsStepState>();
  final _durationKey = GlobalKey<DurationStepState>();
  final _budgetKey = GlobalKey<BudgetStepState>();

  // Ordered list of step widgets displayed in the flow.
  late final List<Widget> _steps;

  // Index of the currently visible step.
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Build the list of steps once; they keep internal state via keys.
    _steps = [
      PersonalInfoStep(key: _personalInfoKey),
      InterestsStep(key: _interestsKey),
      GoalsStep(key: _goalsKey),
      DurationStep(key: _durationKey),
      BudgetStep(key: _budgetKey),
    ];
  }

  void _goNext() {
    // Validate and persist current step; if it fails, don't navigate.
    if (!_persistCurrentStepData()) {
      return;
    }

    // If not on last step, move forward; else navigate to confirmation.
    if (_currentIndex < _steps.length - 1) {
      setState(() => _currentIndex += 1);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const confirmation_step.ConfirmationStep(),
        ),
      );
    }
  }

  void _goBack() {
    // Move back a step if not at the first one.
    if (_currentIndex > 0) {
      setState(() => _currentIndex -= 1);
    }
  }

  bool _persistCurrentStepData() {
    // Access provider without listening to avoid rebuilds.
    final onboardingProvider = context.read<MenteeOnboardingProvider>();

    switch (_currentIndex) {
      case 0:
        // Personal info validation and save.
        final state = _personalInfoKey.currentState;
        if (state == null || !state.validateAndSave()) {
          return false;
        }
        onboardingProvider.setFullName(state.fullName ?? '');
        onboardingProvider.setBirthMonth(state.birthMonth);
        onboardingProvider.setBirthDay(state.birthDay);
        onboardingProvider.setBirthYear(state.birthYear);
        onboardingProvider.setBio(state.bio ?? '');
        onboardingProvider.setAddressDetails(state.addressDetails);
        return true;
      case 1:
        // Interests step save.
        final state = _interestsKey.currentState;
        if (state == null) {
          return true;
        }
        onboardingProvider.setSelectedInterests(state.selectedInterests);
        return true;
      case 2:
        // Goals step save.
        final state = _goalsKey.currentState;
        if (state == null) {
          return true;
        }
        onboardingProvider.setSelectedGoals(state.selectedGoals);
        return true;
      case 3:
        // Duration step validation (must select an option).
        final state = _durationKey.currentState;
        if (state == null) {
          return true;
        }
        if (state.selectedDuration == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a preferred duration.'),
            ),
          );
          return false;
        }
        onboardingProvider.setSelectedDuration(state.selectedDuration);
        return true;
      case 4:
        // Budget step validation and save.
        final state = _budgetKey.currentState;
        if (state == null || !state.validateAndSave()) {
          return false;
        }
        onboardingProvider.setMinBudget(state.minBudget);
        onboardingProvider.setMaxBudget(state.maxBudget);
        return true;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    // We embed the active step inside a Column and provide shared navigation
    // controls so the individual steps don't manage top-level Scaffolds.
    final step = _steps[_currentIndex];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Top progress indicator + title area
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                children: [
                  const Text(
                    'TURO',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text('Step ${_currentIndex + 1} of ${_steps.length}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  final isActive = index <= _currentIndex;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(
                        right: index < _steps.length - 1 ? 8 : 0,
                      ),
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

            // The active step expands to take remaining space
            Expanded(child: step),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10403B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _steps.length - 1 ? 'Next' : 'Finish',
                    style: const TextStyle(
                      color: Color(0xFFFEFEFE),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_currentIndex > 0) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _goBack,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C6A64),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
