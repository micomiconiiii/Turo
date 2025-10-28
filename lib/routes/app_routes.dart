import 'package:flutter/material.dart';
import '../presentation/mentor_registration_screen/mentor_registration_screen.dart';
import '../presentation/mentor_registration_screen/id_upload_screen.dart';
import '../presentation/mentor_registration_screen/selfie_verification_screen.dart';
import '../presentation/mentor_registration_screen/institutional_verification_screen.dart';
import '../presentation/mentor_registration_screen/credentials_achievements_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';

import '../presentation/mentor_registration_screen/otp_screen.dart';

class AppRoutes {
  static const String mentorRegistrationScreen = '/mentor_registration_screen';
  static const String idUploadScreen = '/id_upload_screen';
  static const String selfieVerificationScreen = '/selfie_verification_screen';
  static const String institutionalVerificationScreen = '/institutional_verification_screen';
  static const String credentialsAchievementsScreen = '/credentials_achievements_screen';
  static const String otpScreen = '/otp_screen';
  static const String appNavigationScreen = '/app_navigation_screen';

  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        mentorRegistrationScreen: (context) => MentorRegistrationScreen(),
        idUploadScreen: (context) => IdUploadScreen(),
        selfieVerificationScreen: (context) => SelfieVerificationScreen(),
        institutionalVerificationScreen: (context) =>
            InstitutionalVerificationScreen(),
        credentialsAchievementsScreen: (context) =>
            CredentialsAchievementsScreen(),
        otpScreen: (context) => OtpScreen(),
        appNavigationScreen: (context) => AppNavigationScreen(),
        initialRoute: (context) => AppNavigationScreen()
      };
}
