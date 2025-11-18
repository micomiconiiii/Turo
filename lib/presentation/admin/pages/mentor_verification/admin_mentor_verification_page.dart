import 'package:flutter/material.dart';

/// Admin Mentor Verification Page
///
/// Displays the queue of mentor applications pending verification.
/// Allows admins to review credentials, approve, or reject applications.
class AdminMentorVerificationPage extends StatelessWidget {
  const AdminMentorVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mentor Verification Queue',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
