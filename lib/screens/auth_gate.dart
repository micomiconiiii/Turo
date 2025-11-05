import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_profile_screen.dart'; // Your main screen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // This is a simple, temporary login for testing
  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print("Signed in anonymously!");
    } catch (e) {
      print("Failed to sign in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to auth state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If user is not logged in, show a login button
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                child: const Text("Sign In for Testing"),
                onPressed: _signInAnonymously,
              ),
            ),
          );
        }

        // If user IS logged in, show the MyProfileScreen
        return const MyProfileScreen();
      },
    );
  }
}