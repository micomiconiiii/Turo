import 'package:flutter/material.dart';
import '../presentation/mentor_registration_screen/mentor_registration_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String mentorRegistrationScreen = '/mentor_registration_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        mentorRegistrationScreen: (context) => MentorRegistrationScreen(),
        appNavigationScreen: (context) => AppNavigationScreen(),
        initialRoute: (context) => AppNavigationScreen()
      };
}
