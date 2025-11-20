import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turo/presentation/app_navigation_screen/app_navigation_screen.dart';
import 'package:turo/presentation/login_screen/login_screen.dart';
import '../services/auth_service.dart';

/// AuthWrapper checks authentication state and routes accordingly.
///
/// This widget uses AuthService to monitor auth state changes.
/// - If user is authenticated → AppNavigationScreen
/// - If user is not authenticated → LoginScreen
///
/// This is the proper implementation of Service + Model pattern:
/// AuthWrapper → AuthService → FirebaseAuth.instance (backend)
class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Use AuthService's auth stream instead of calling Firebase directly
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // TODO: In the future, check user role and onboarding status
          // from Firestore and route accordingly:
          // - Mentee with incomplete onboarding → MenteeOnboardingPage
          // - Mentor with incomplete registration → MentorRegistrationScreen
          // - Completed users → AppNavigationScreen
          return AppNavigationScreen();
        }

        // User is not logged in
        return LoginScreen();
      },
    );
  }
}
