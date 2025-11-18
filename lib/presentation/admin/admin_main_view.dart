import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turo/services/database_service.dart';
import 'package:turo/models/notification_model.dart';
import 'widgets/admin_side_menu.dart';
import 'pages/dashboard/admin_dashboard_page.dart';
import 'pages/mentor_verification/admin_mentor_verification_page.dart';
import 'pages/user_management/admin_user_management_page.dart';
import 'pages/contracts/admin_contracts_page.dart';
import 'pages/financials/admin_financials_page.dart';
import 'pages/reports/admin_reports_page.dart';
import 'pages/announcements/admin_announcements_page.dart';
import 'pages/settings/admin_settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin Panel Main View - The Shell for Admin Navigation
///
/// This is the root container for the entire admin panel.
/// It contains the side navigation menu and dynamically displays
/// the selected page in the main content area.
class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  int _selectedIndex = 0;
  DatabaseService? _databaseService; // lazy to avoid Firebase init races

  // List of all admin pages corresponding to navigation items
  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminMentorVerificationPage(),
    const AdminUserManagementPage(),
    const AdminContractsPage(),
    const AdminFinancialsPage(),
    const AdminReportsPage(),
    const AdminAnnouncementsPage(),
    const AdminSettingsPage(),
  ];

  // Page titles corresponding to navigation items
  final List<String> _pageTitles = [
    'Dashboard',
    'Mentor Verification',
    'User Management',
    'Contracts & Disputes',
    'Financials',
    'Reports',
    'Announcements',
    'Settings',
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side Navigation Menu
          AdminSideMenu(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
          ),

          // Main Content Area with Header
          Expanded(
            child: Column(
              children: [
                // Top Header
                _buildHeader(context),

                // Page Content
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F5F5), // Light grey background
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the top header with page title and admin profile
  Widget _buildHeader(BuildContext context) {
    final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final hasFirebase = Firebase.apps.isNotEmpty;
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page Title
          Text(
            _pageTitles[_selectedIndex],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF10403B),
              fontFamily: 'Inter',
            ),
          ),

          // Admin Profile & Notifications
          Row(
            children: [
              // Notifications Icon (live)
              StreamBuilder<List<NotificationModel>>(
                stream: (hasFirebase && adminId.isNotEmpty)
                    ? ((_databaseService ??= DatabaseService())
                          .streamAdminNotifications(adminId, limit: 10))
                    : null,
                builder: (context, snapshot) {
                  final unread = snapshot.data ?? const <NotificationModel>[];
                  final count = unread.length;
                  return IconButton(
                    onPressed: () {
                      if (count == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No unread notifications'),
                          ),
                        );
                        return;
                      }
                      _showHeaderNotificationsDialog(unread);
                    },
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF10403B),
                          size: 26,
                        ),
                        if (count > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              // Admin Profile
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF10403B),
                      child: const Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10403B),
                          ),
                        ),
                        Text(
                          'Administrator',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF414480),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF414480),
                    ),
                  ],
                ),
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (String value) {
                  if (value == 'logout') {
                    // TODO: Implement logout
                    Navigator.of(context).pushReplacementNamed('/admin-login');
                  } else if (value == 'settings') {
                    setState(() {
                      _selectedIndex = 7; // Navigate to Settings page
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHeaderNotificationsDialog(List<NotificationModel> unread) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10403B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: unread.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final n = unread[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C6A64).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getHeaderNotifIcon(n.type),
                                color: const Color(0xFF2C6A64),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getHeaderNotifTitle(n.type),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF10403B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.message,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: const Color(
                                        0xFF10403B,
                                      ).withOpacity(0.55),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _relativeTime(n.createdAt),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: const Color(
                                        0xFF10403B,
                                      ).withOpacity(0.35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (n.id != null)
                              TextButton(
                                onPressed: () async {
                                  final db = _databaseService ??=
                                      DatabaseService();
                                  await db.markNotificationAsRead(n.id!);
                                  if (mounted) Navigator.of(ctx).pop();
                                },
                                child: const Text('Mark read'),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() => _selectedIndex = 0);
                        },
                        child: const Text('View dashboard'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getHeaderNotifIcon(String type) {
    switch (type) {
      case 'verification':
        return Icons.pending_actions;
      case 'dispute':
        return Icons.report_problem;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _getHeaderNotifTitle(String type) {
    switch (type) {
      case 'verification':
        return 'New mentor verification';
      case 'dispute':
        return 'Dispute reported';
      case 'payment':
        return 'Payment completed';
      default:
        return 'Notification';
    }
  }

  String _relativeTime(Timestamp ts) {
    final now = DateTime.now();
    final dt = ts.toDate();
    final d = now.difference(dt);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) {
      final h = d.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (d.inDays < 7) {
      final dd = d.inDays;
      return '$dd ${dd == 1 ? 'day' : 'days'} ago';
    }
    final w = (d.inDays / 7).floor();
    return '$w ${w == 1 ? 'week' : 'weeks'} ago';
  }
}
