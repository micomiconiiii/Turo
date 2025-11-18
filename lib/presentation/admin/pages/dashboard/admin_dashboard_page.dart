import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/database_service.dart';
import '../../../../models/notification_model.dart';
import '../../../../models/activity_model.dart';

/// Admin Dashboard Page
///
/// The main landing page for administrators.
/// Displays key metrics, recent activities, and quick action buttons.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _seeding = false;

  Future<void> _seedData(String adminId) async {
    if (adminId.isEmpty) return;
    setState(() => _seeding = true);
    try {
      await _databaseService.seedSampleData(adminId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample data seeded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to seed data: $e')));
      }
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9FA),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _databaseService.getAdminDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C6A64)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading dashboard data',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF414480),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final stats =
              snapshot.data ??
              {
                'total_mentees': 0,
                'total_mentors': 0,
                'new_users': 0,
                'mentees_change': 0.0,
                'mentors_change': 0.0,
                'new_users_change': 0.0,
              };

          return _buildDashboardContent(context, stats);
        },
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final isWideScreen = MediaQuery.of(context).size.width > 1200;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildMainContent(stats)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildRightPanel()),
              ],
            )
          else
            Column(
              children: [
                _buildMainContent(stats),
                const SizedBox(height: 24),
                _buildRightPanel(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(Map<String, dynamic> stats) {
    // Extract percentage changes and format them
    final menteesChange = stats['mentees_change'] as double? ?? 0.0;
    final mentorsChange = stats['mentors_change'] as double? ?? 0.0;
    final newUsersChange = stats['new_users_change'] as double? ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Cards Row
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                title: 'Mentees',
                count: stats['total_mentees'] as int? ?? 0,
                icon: Icons.school,
                percentageChange: _formatPercentageChange(menteesChange),
                isPositive: menteesChange >= 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AdminStatCard(
                title: 'Mentors',
                count: stats['total_mentors'] as int? ?? 0,
                icon: Icons.verified_user,
                percentageChange: _formatPercentageChange(mentorsChange),
                isPositive: mentorsChange >= 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AdminStatCard(
                title: 'New Users',
                count: stats['new_users'] as int? ?? 0,
                icon: Icons.person_add,
                percentageChange: _formatPercentageChange(newUsersChange),
                isPositive: newUsersChange >= 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Total Users Graph Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Users',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414480),
                    ),
                  ),
                  _buildOperatingStatusLegend(),
                ],
              ),
              const SizedBox(height: 16),
              // User Growth Chart (dynamic height to avoid overflow on shorter screens)
              SizedBox(
                height: () {
                  final h =
                      MediaQuery.of(context).size.height *
                      0.30; // target ~30% of viewport
                  return h
                      .clamp(180, 220)
                      .toDouble(); // keep within sensible bounds
                }(),
                child: FutureBuilder<Map<String, List<dynamic>>>(
                  future: _databaseService.getUserGrowthChartData(),
                  builder: (context, chartSnapshot) {
                    if (chartSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2C6A64),
                        ),
                      );
                    }

                    if (chartSnapshot.hasError ||
                        !chartSnapshot.hasData ||
                        chartSnapshot.data!['dates']!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 64,
                              color: Color(0xFF2C6A64).withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No data available',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF414480).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final chartData = chartSnapshot.data!;
                    return _buildUserGrowthChart(chartData);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingStatusLegend() {
    return Row(
      children: [
        _buildLegendItem('Mentors', Color(0xFF2C6A64)),
        const SizedBox(width: 16),
        _buildLegendItem('Mentees', Color(0xFF5FA89A)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF414480),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    // Get current admin user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    final adminId = currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notifications Section - Real-time Stream
        StreamBuilder<List<NotificationModel>>(
          stream: _databaseService.streamAdminNotifications(adminId, limit: 5),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildNotificationContainer(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF2C6A64)),
                  ),
                ),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return _buildNotificationContainer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading notifications',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Data state
            final notifications = snapshot.data ?? [];
            final unreadCount = notifications.length;

            return _buildNotificationContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with count badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10403B),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Only show badge if there are unread notifications
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (kDebugMode) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: 'Seed sample data (debug only)',
                              child: IconButton(
                                icon: _seeding
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_chart_rounded),
                                onPressed: _seeding
                                    ? null
                                    : () => _seedData(adminId),
                                splashRadius: 18,
                                color: const Color(0xFF2C6A64),
                                tooltip: 'Seed sample data',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notification list with slightly smaller adaptive height
                  SizedBox(
                    height: () {
                      final h =
                          MediaQuery.of(context).size.height *
                          0.24; // ~24% of screen
                      return h.clamp(160, 200).toDouble();
                    }(),
                    child: notifications.isEmpty
                        ? Center(
                            child: Text(
                              'No notifications',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF414480).withOpacity(0.5),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: notifications.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return InkWell(
                                onTap: () async {
                                  // Tap-to-mark-as-read
                                  final id = notification.id;
                                  if (id != null) {
                                    try {
                                      await _databaseService
                                          .markNotificationAsRead(id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Notification marked as read',
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to mark as read: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: AdminNotificationItem(
                                  icon:
                                      _getNotificationIcon(notification.type),
                                  title:
                                      _getNotificationTitle(notification.type),
                                  subtitle: notification.message,
                                  time:
                                      _getRelativeTime(notification.createdAt),
                                  iconColor: _getNotificationColor(
                                    notification.type,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // Recent Activities Section - Real-time Stream
        StreamBuilder<List<ActivityModel>>(
          stream: _databaseService.streamRecentActivities(limit: 5),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildActivityContainer(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF2C6A64)),
                  ),
                ),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return _buildActivityContainer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading activities',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Data state
            final activities = snapshot.data ?? [];

            return _buildActivityContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10403B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity list with slightly smaller adaptive height (match notifications)
                  SizedBox(
                    height: () {
                      final h = MediaQuery.of(context).size.height * 0.24;
                      return h.clamp(160, 200).toDouble();
                    }(),
                    child: activities.isEmpty
                        ? Center(
                            child: Text(
                              'No recent activities',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF414480).withOpacity(0.5),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: activities.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final activity = activities[index];
                              return AdminActivityItem(
                                icon: _getActivityIcon(activity.eventType),
                                title: activity.eventType
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                                subtitle: activity.description,
                                time: activity.getRelativeTime(),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper method to build notification container
  Widget _buildNotificationContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper method to build activity container
  Widget _buildActivityContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Get icon based on notification type
  IconData _getNotificationIcon(String type) {
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

  // Get title based on notification type
  String _getNotificationTitle(String type) {
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

  // Get color based on notification type
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'verification':
        return const Color(0xFF2C6A64);
      case 'dispute':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      default:
        return const Color(0xFF414480);
    }
  }

  // Get icon based on activity type
  IconData _getActivityIcon(String eventType) {
    switch (eventType) {
      case 'user_registered':
        return Icons.person_add_outlined;
      case 'mentor_approved':
        return Icons.check_circle_outline;
      case 'contract_created':
        return Icons.handshake_outlined;
      case 'payment_completed':
        return Icons.payment;
      case 'dispute_opened':
        return Icons.report_problem;
      default:
        return Icons.circle_outlined;
    }
  }

  // Get relative time string
  String _getRelativeTime(Timestamp timestamp) {
    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    }
  }

  /// Builds the user growth line chart
  Widget _buildUserGrowthChart(Map<String, List<dynamic>> chartData) {
    final dates = chartData['dates'] as List<String>;
    final menteeCounts = chartData['mentees'] as List<int>;
    final mentorCounts = chartData['mentors'] as List<int>;

    // Create spots for mentees line
    final menteeSpots = menteeCounts
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    // Create spots for mentors line
    final mentorSpots = mentorCounts
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    // Calculate max Y value for better scaling
    final maxMentees = menteeCounts.fold(0, (a, b) => a > b ? a : b);
    final maxMentors = mentorCounts.fold(0, (a, b) => a > b ? a : b);
    final maxY = (maxMentees > maxMentors ? maxMentees : maxMentors).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 12, bottom: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? (maxY / 4) : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFF414480).withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dates.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dates[index],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: const Color(0xFF414480).withOpacity(0.6),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY > 0 ? (maxY / 4) : 1,
                reservedSize: 32,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: const Color(0xFF414480).withOpacity(0.6),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF414480).withOpacity(0.2),
              ),
              left: BorderSide(color: const Color(0xFF414480).withOpacity(0.2)),
            ),
          ),
          minX: 0,
          maxX: (dates.length - 1).toDouble(),
          minY: 0,
          maxY: maxY > 0 ? maxY + 1 : 5,
          lineBarsData: [
            // Mentors line
            LineChartBarData(
              spots: mentorSpots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF2C6A64), Color(0xFF2C6A64)],
              ),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF2C6A64),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2C6A64).withOpacity(0.2),
                    const Color(0xFF2C6A64).withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Mentees line
            LineChartBarData(
              spots: menteeSpots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF5FA89A), Color(0xFF5FA89A)],
              ),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF5FA89A),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5FA89A).withOpacity(0.2),
                    const Color(0xFF5FA89A).withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final isMentor = touchedSpot.barIndex == 0;
                  return LineTooltipItem(
                    '${isMentor ? 'Mentors' : 'Mentees'}: ${touchedSpot.y.toInt()}\n',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(
                        text: dates[touchedSpot.x.toInt()],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 9,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Formats percentage change value to display string
  ///
  /// Returns formatted string like "+5.2%" or "-3.1%" or "0.0%"
  String _formatPercentageChange(double change) {
    if (change == 0.0) {
      return '0.0%';
    }
    final sign = change > 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }
}

// ========== REUSABLE WIDGETS ==========

/// Stat Card Widget
///
/// Displays a metric with icon, count, and percentage change.
class AdminStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final String percentageChange;
  final bool isPositive;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.percentageChange,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C6A64),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C6A64).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? Colors.greenAccent : Colors.redAccent,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      percentageChange,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification Item Widget
///
/// Displays a notification with icon, title, subtitle, and timestamp.
class AdminNotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color iconColor;

  const AdminNotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.iconColor = const Color(0xFF2C6A64),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10403B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF10403B).withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF10403B).withOpacity(0.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Activity Item Widget
///
/// Displays a recent activity with icon, title, subtitle, and timestamp.
class AdminActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const AdminActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF2C6A64).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Color(0xFF2C6A64), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10403B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF10403B).withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF10403B).withOpacity(0.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
