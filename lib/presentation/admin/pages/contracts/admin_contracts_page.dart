import 'package:flutter/material.dart';

/// Admin Contracts & Disputes Page
///
/// Displays all mentorship contracts and manages dispute resolution.
/// Allows admins to view contract details, monitor status, and handle disputes.
class AdminContractsPage extends StatelessWidget {
  const AdminContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contracts & Disputes',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
