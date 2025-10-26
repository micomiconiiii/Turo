import 'package:flutter/material.dart';
// Import MyProfileScreen instead
import 'screens/my_profile_screen.dart'; // <-- CHANGE IMPORT
// Remove the import for ProfileSetupScreen if it's not used elsewhere in main.dart
// import 'screens/profile_setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Turo App', // Changed title slightly
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4D44)), // Use your brand color
        useMaterial3: true,
      ),
      // Set MyProfileScreen as the starting point
      home: const MyProfileScreen(), // <-- CHANGE HERE
    );
  }
}