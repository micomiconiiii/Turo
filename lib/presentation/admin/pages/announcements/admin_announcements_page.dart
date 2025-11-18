import 'package:flutter/material.dart';

/// Admin Announcements Page
///
/// Manages platform-wide announcements and notifications.
/// Allows admins to create, edit, schedule, and publish announcements to users.
class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Announcements',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
