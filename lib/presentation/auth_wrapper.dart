import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turo/presentation/app_navigation_screen/app_navigation_screen.dart';
import 'package:turo/presentation/mentor_registration_screen/mentor_registration_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.hasData) {
          return AppNavigationScreen(); // Or your home screen
        }
        // User is not logged in
        else {
          // You should probably have a dedicated login/signup screen here
          // For now, I'm directing to the registration screen as per the flow
          return AppNavigationScreen(); 
        }
      },
    );
  }
}
