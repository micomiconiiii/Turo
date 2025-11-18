import 'package:flutter/material.dart';

/// Admin Financials & Escrow Page
///
/// Manages financial transactions, escrow accounts, and payment processing.
/// Displays transaction history, pending payments, and financial reports.
class AdminFinancialsPage extends StatelessWidget {
  const AdminFinancialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Financials & Escrow',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
