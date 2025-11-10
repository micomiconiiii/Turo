// Minimal Flutter widget import (no material) for route builders.
import 'package:flutter/widgets.dart';
// The onboarding page shown at app start.
import 'package:turo_app/mentee_onboarding/pages/mentee_onboarding_page.dart';

/// Centralized named routes for the application.
class AppRoutes {
  // Private constructor to prevent creating instances; use static members only.
  AppRoutes._(); // private constructor to prevent instantiation

  /// Route name for the mentee onboarding screen.
  static const String menteeOnboardingScreen = '/mentee_onboarding_screen';

  /// The app's initial route. Currently points to the mentee onboarding.
  static const String initialRoute = menteeOnboardingScreen;

  /// Map of named routes used by the app.
  static Map<String, WidgetBuilder> get routes {
    // Return a map from route name to builder function.
    return {
      // The provider is now at the app root, so just return the page.
      menteeOnboardingScreen: (context) => const MenteeOnboardingPage(),
    };
  }
}
