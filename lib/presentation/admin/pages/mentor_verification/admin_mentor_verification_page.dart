import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:turo/services/admin_service.dart';
import 'package:turo/models/mentor_verification_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher to pubspec.yaml if you want "Open Link" to work

class AdminMentorVerificationPage extends StatefulWidget {
  const AdminMentorVerificationPage({super.key});

  @override
  State<AdminMentorVerificationPage> createState() =>
      _AdminMentorVerificationPageState();
}

class _AdminMentorVerificationPageState
    extends State<AdminMentorVerificationPage> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Debug Seeder Button
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                await _adminService.seedPendingMentor();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Test Mentor Generated!')),
                  );
                }
              },
              label: const Text("Seed Data"),
              icon: const Icon(Icons.science),
              backgroundColor: const Color(0xFF10403B),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(
          32.0,
        ), // Increased padding for cleaner look
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10403B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF10403B),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mentor Verification Queue',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10403B),
                      ),
                    ),
                    Text(
                      'Review credentials and approve mentor applications.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: const Color(0xFF414480).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Main Table Card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: StreamBuilder<List<MentorVerificationModel>>(
                    stream: _adminService.streamPendingVerifications(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return _buildErrorState(snapshot.error);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF10403B),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final requests = snapshot.data!;

                      return Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.grey.shade200,
                          dataTableTheme: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFFF9F9FA),
                            ),
                            headingTextStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            dataRowColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                            dataTextStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 24,
                            horizontalMargin: 32,
                            headingRowHeight: 50,
                            dataRowMinHeight: 60,
                            dataRowMaxHeight: 60,
                            columns: const [
                              DataColumn(label: Text('APPLICANT UID')),
                              DataColumn(label: Text('SUBMITTED DATE')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('ACTION')),
                            ],
                            rows: requests.map((req) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          req.uid.length > 8
                                              ? "${req.uid.substring(0, 8)}..."
                                              : req.uid,
                                          style: const TextStyle(
                                            fontFamily: 'RobotoMono',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      "${req.submittedAt.day}/${req.submittedAt.month}/${req.submittedAt.year}",
                                    ),
                                  ),
                                  DataCell(_buildStatusBadge(req.status)),
                                  DataCell(
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showReviewDialog(context, req),
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 16,
                                      ),
                                      label: const Text('Review'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF10403B,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10403B).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: const Color(0xFF10403B).withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10403B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No pending verifications at the moment.',
            style: TextStyle(fontFamily: 'Inter', color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            "Unable to load data",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "$error",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // --- REVIEW DIALOG ---

  void _showReviewDialog(
    BuildContext context,
    MentorVerificationModel request,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String userName = await _adminService.getMentorName(request.uid);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: Container(
          width: 900,
          height: 750,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review Application',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10403B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'UID: ${request.uid}',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
              const Divider(height: 48),

              // --- CONTENT AREA ---
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: IMAGES
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "IDENTITY DOCUMENTS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildImageCard(
                                    'Real-time Selfie',
                                    request.selfieUrl,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildImageCard(
                                    'Government ID',
                                    request.idUrl,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 32),

                    // RIGHT COLUMN: DETAILS
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PROFESSIONAL DETAILS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // DETAILS CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // LEGACY DATA CHECK
                                if (request.credentials.isEmpty &&
                                    (request.institutionName != null ||
                                        request.jobTitle != null)) ...[
                                  _buildDetailRow(
                                    Icons.business,
                                    "Institution",
                                    request.institutionName ?? 'N/A',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    Icons.work,
                                    "Job Title",
                                    request.jobTitle ?? 'N/A',
                                  ),
                                ]
                                // NEW SCHEMA CHECK
                                else if (request.credentials.isNotEmpty) ...[
                                  Text(
                                    "${request.credentials.length} Files Attached",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...request.credentials.map(
                                    (cred) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Launch URL
                                        },
                                        icon: const Icon(
                                          Icons.file_present,
                                          size: 16,
                                        ),
                                        label: Text(cred.fileName),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(
                                            0xFF10403B,
                                          ),
                                          elevation: 0,
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          alignment: Alignment.centerLeft,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else
                                  const Text(
                                    "No details provided.",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ACTIONS FOOTER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Ensure the ID matches the selfie and professional details before approving.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          _handleAction(context, request.uid, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                      ),
                      child: const Text('Reject Application'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _handleAction(context, request.uid, true),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve Mentor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10403B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF10403B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(String title, String url) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                      child: CircularProgressIndicator(color: Colors.grey[300]),
                    ),
                    errorWidget: (_, __, ___) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Unable to load image\n(Check CORS)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Overlay Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: title, // Unique tag per button
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.open_in_new, color: Colors.black87),
                    onPressed: () async {
                      if (url.isNotEmpty) {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    String uid,
    bool isApprove,
  ) async {
    Navigator.pop(context); // Close dialog

    try {
      if (isApprove) {
        await _adminService.approveMentor(uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mentor Approved Successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _adminService.rejectMentor(uid, "Admin Rejection");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mentor Application Rejected"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error processing request: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
