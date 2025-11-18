import 'package:flutter/material.dart';

/// Admin User Management Page
///
/// Provides a directory of all users (mentors and mentees).
/// Allows admins to search, filter, view details, suspend, or delete users.
class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'User Management Directory',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
