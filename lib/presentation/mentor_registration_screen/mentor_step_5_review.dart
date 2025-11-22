import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- FIXED IMPORTS (Using absolute paths) ---
import '../../../services/database_service.dart';
import 'providers/mentor_registration_provider.dart'; // Keep relative if in same folder

class MentorStep5Review extends StatefulWidget {
  const MentorStep5Review({super.key});

  @override
  State<MentorStep5Review> createState() => _MentorStep5ReviewState();
}

class _MentorStep5ReviewState extends State<MentorStep5Review> {
  bool _isLoading = false;

  Future<void> _onSubmit() async {
    final provider = context.read<MentorRegistrationProvider>();

    // --- THE FIX: Instantiate directly ---
    // If this line is still red, ensure 'database_service.dart' is in 'lib/services/'
    final dbService = DatabaseService();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await provider.submitApplication(uid, dbService);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application Submitted Successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to the very start (Login or Dashboard)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C6A64),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(fontSize: 15),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String label, XFile? file) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C6A64),
            ),
          ),
          const SizedBox(height: 8),
          file != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(
                          file.path,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(file.path),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                )
              : const Text(
                  'No image uploaded',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MentorRegistrationProvider>(
      builder: (context, provider, _) {
        // Construct clean address string
        final addressParts = [
          provider.unit,
          provider.street,
          provider.barangay,
          provider.city,
          provider.province,
          provider.zipCode,
        ].where((part) => part.isNotEmpty).join(', ');

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review & Confirm',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C6A64),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Please review your details before submitting.'),
              const SizedBox(height: 24),
              _buildReviewField('Full Name', provider.fullName),
              _buildReviewField('Bio', provider.bio),
              _buildReviewField('Address', addressParts),
              _buildReviewField('Institution', provider.institutionName),
              _buildReviewField('Position', provider.jobTitle),
              _buildReviewField(
                'Hourly Rate',
                'PHP ${provider.hourlyRate?.toStringAsFixed(2) ?? "0.00"}',
              ),
              _buildReviewField('Expertise', provider.expertise.join(', ')),
              _buildImagePreview('Government ID', provider.idFile),
              _buildImagePreview('Selfie', provider.selfieFile),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2C6A64),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm & Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
