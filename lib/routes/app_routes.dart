import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/user_model.dart';

// --- NAVIGATION & SPLASH ---
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';

// --- AUTH & LEGAL ---
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_registration_screen/user_registration_screen.dart';
import '../presentation/terms_and_conditions_screen/terms_and_conditions_screen.dart';

// --- MENTOR REGISTRATION (UPDATED) ---
// Note: Ensure these paths match your actual folder structure.
// If your folder is named 'mentor_registration', remove '_screen' from the path below.
import '../presentation/mentor_registration_screen/mentor_registration_page.dart';
import '../presentation/mentor_registration_screen/providers/mentor_registration_provider.dart';
import '../presentation/mentor_registration_screen/otp_verification_screen.dart';

// --- MENTEE ONBOARDING ---
import '../presentation/mentee_onboarding/pages/mentee_onboarding_page.dart';
import '../presentation/mentee_onboarding/providers/mentee_onboarding_provider.dart';

class AppRoutes {
  static const String mentorRegistrationScreen = '/mentor_registration_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String emailVerificationScreen = '/email_verification_screen';
  static const String termsAndConditionsScreen = '/terms_and_conditions_screen';
  static const String splashScreen = '/splash_screen';
  static const String loginScreen = '/login_screen';
  static const String userRegistrationScreen = '/user_registration_screen';
  static const String menteeOnboardingPage = '/mentee_onboarding_page';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    // --- UPDATED MENTOR ROUTE ---
    mentorRegistrationScreen: (context) => ChangeNotifierProvider(
      create: (_) => MentorRegistrationProvider(),
      child: const MentorRegistrationPage(),
    ),

    // --- EXISTING ROUTES ---
    emailVerificationScreen: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return OtpVerificationScreen(
        email: args['email'] as String,
        user: args['user'] as UserModel?,
        userDetail: args['userDetail'] as UserDetailModel?,
        password: args['password'] as String?,
        role: args['role'] as String?,
      );
    },
    menteeOnboardingPage: (context) => ChangeNotifierProvider(
      create: (_) => MenteeOnboardingProvider(),
      child: const MenteeOnboardingPage(),
    ),
    appNavigationScreen: (context) => AppNavigationScreen(),
    initialRoute: (context) => AppNavigationScreen(),
    termsAndConditionsScreen: (context) => TermsAndConditionsScreen(),
    splashScreen: (context) => SplashScreen(),
    loginScreen: (context) => LoginScreen(),
    userRegistrationScreen: (context) => UserRegistrationScreen(),
  };
}
