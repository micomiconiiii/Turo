import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_registration_screen/user_registration_screen.dart';
import '../presentation/mentor_registration_screen/mentor_registration_screen.dart';
import '../presentation/terms_and_conditions_screen/terms_and_conditions_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String splashScreen =
      '/splash_screen'; // Modified: Removed duplicate definitions
  static const String loginScreen = '/login_screen';
  static const String userRegistrationScreen = '/user_registration_screen';
  static const String mentorRegistrationScreen = '/mentor_registration_screen';
  static const String termsAndConditionsScreen = '/terms_and_conditions_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        splashScreen: (context) =>
            SplashScreen(), // Modified: Removed duplicate route entries
        loginScreen: (context) => LoginScreen(),
        userRegistrationScreen: (context) => UserRegistrationScreen(),
        mentorRegistrationScreen: (context) => MentorRegistrationScreen(),
        termsAndConditionsScreen: (context) => TermsAndConditionsScreen(),
        appNavigationScreen: (context) => AppNavigationScreen(),
        initialRoute: (context) => AppNavigationScreen()
      };
}
