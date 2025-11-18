import 'package:flutter/material.dart';

/// Admin Settings Page
///
/// Configures platform settings, admin roles, and system preferences.
/// Includes security settings, notification preferences, and system configuration.
class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
