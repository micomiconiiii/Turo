import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:turo/models/notification_model.dart';
import 'package:turo/models/activity_model.dart';

/// Service class for managing database operations with Firestore.
///
/// This service implements the new 3-Layer Schema:
/// - Layer 1: users (public hub with display info and nested profiles)
/// - Layer 2: user_details (private data like email, birthdate, address)
/// - Layer 3: mentor_verifications (verification documents for mentors)
///
/// Uses batched writes to ensure atomicity when writing multiple documents.
class DatabaseService {
  // Private instance of Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'turo',
  );

  // Collection name constants for the new 3-Layer Schema
  final String _usersCollection = "users";
  final String _userDetailsCollection = "user_details";
  // ignore: unused_field
  final String _mentorVerificationsCollection = "mentor_verifications";
  final String _notificationsCollection = "notifications";
  final String _activitiesCollection = "activities";

  /// Creates initial user documents during signup.
  ///
  /// This method atomically creates both the public user document and
  /// the private user_details document using a batched write.
  ///
  /// [uid] - The unique identifier for the user (Firebase Auth UID)
  /// [email] - The user's email address
  /// [role] - The user's role ("mentee" or "mentor")
  ///
  /// Throws [FirebaseException] if the batch write fails.
  Future<void> createInitialUser(String uid, String email, String role) async {
    final WriteBatch batch = _db.batch();

    final userDoc = _db.collection('users').doc(uid);
    final Map<String, dynamic> userData = {
      'display_name': email.split('@')[0],
      'roles': [role],
      'is_verified': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
    batch.set(userDoc, userData);

    final userDetailDoc = _db.collection('user_details').doc(uid);
    final Map<String, dynamic> userDetailData = {
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
    };
    batch.set(userDetailDoc, userDetailData);

    await batch.commit();
  }

  /// Updates user data after mentee onboarding completion.
  ///
  /// This method atomically updates both the public user document (with display
  /// info and nested mentee_profile) and the private user_details document
  /// (with birthdate and address) using a batched write.
  ///
  /// [uid] - The unique identifier for the user
  /// [user] - The UserModel containing display info and nested mentee profile
  /// [userDetail] - The UserDetailModel containing private data
  ///
  /// Throws [FirebaseException] if the batch write fails.
  Future<void> updateMenteeOnboardingData(
    String uid,
    UserModel user,
    UserDetailModel userDetail,
  ) async {
    // Create a batched write for atomicity
    final WriteBatch batch = _db.batch();

    // Update the public users document
    final userRef = _db.collection(_usersCollection).doc(uid);
    final Map<String, dynamic> userUpdate = {
      ...user.toFirestore(),
      // Always refresh updated_at on any user update
      'updated_at': FieldValue.serverTimestamp(),
    };
    batch.update(userRef, userUpdate);

    // Update the private user_details document
    batch.update(
      _db.collection(_userDetailsCollection).doc(uid),
      userDetail.toFirestore(),
    );

    // Commit the batch (all or nothing)
    await batch.commit();
  }

  /// Retrieves a user document from the users collection.
  ///
  /// Returns the DocumentSnapshot containing public user data.
  ///
  /// [userId] - The unique identifier for the user
  Future<DocumentSnapshot> getUser(String userId) async {
    return _db.collection(_usersCollection).doc(userId).get();
  }

  /// Retrieves a user_details document.
  ///
  /// Returns the DocumentSnapshot containing private user data.
  ///
  /// [userId] - The unique identifier for the user
  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return _db.collection(_userDetailsCollection).doc(userId).get();
  }

  /// Retrieves admin dashboard statistics with percentage changes.
  ///
  /// Returns a Map containing counts and percentage changes for:
  /// - 'total_mentees': Total number of users with 'mentee' role
  /// - 'total_mentors': Total number of users with 'mentor' role
  /// - 'new_users': Number of users created in the last 7 days
  /// - 'mentees_change': Percentage change in mentees (last 7 days vs previous 7 days)
  /// - 'mentors_change': Percentage change in mentors (last 7 days vs previous 7 days)
  /// - 'new_users_change': Percentage change in new users (last 7 days vs previous 7 days)
  ///
  /// Used by the admin dashboard to display platform statistics with trends.
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final fourteenDaysAgo = now.subtract(const Duration(days: 14));

      // Get total mentees count (no composite index required)
      final menteesSnapshot = await _db
          .collection(_usersCollection)
          .where('roles', arrayContains: 'mentee')
          .count()
          .get();
      final totalMentees = menteesSnapshot.count ?? 0;

      // Get total mentors count (no composite index required)
      final mentorsSnapshot = await _db
          .collection(_usersCollection)
          .where('roles', arrayContains: 'mentor')
          .count()
          .get();
      final totalMentors = mentorsSnapshot.count ?? 0;

      // Fetch users touched in the last 14 days by created_at OR updated_at
      final createdQuery = _db
          .collection(_usersCollection)
          .where(
            'created_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fourteenDaysAgo),
          )
          .get();
      final updatedQuery = _db
          .collection(_usersCollection)
          .where(
            'updated_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fourteenDaysAgo),
          )
          .get();
      final results = await Future.wait([createdQuery, updatedQuery]);
      final Map<String, Map<String, dynamic>> docsById = {};
      for (final snap in results) {
        for (final doc in snap.docs) {
          docsById[doc.id] = doc.data();
        }
      }

      int recentMentees = 0;
      int previousMentees = 0;
      int recentMentors = 0;
      int previousMentors = 0;
      int newUsers = 0;
      int previousNewUsers = 0;

      for (final data in docsById.values) {
        final ts = data['created_at'] ?? data['updated_at'];
        if (ts == null || ts is! Timestamp) continue; // skip if missing/invalid
        final createdAt = ts.toDate();
        final roles = (data['roles'] as List?)?.cast<dynamic>() ?? const [];

        final inRecent =
            createdAt.isAfter(sevenDaysAgo) ||
            createdAt.isAtSameMomentAs(sevenDaysAgo);
        final inPrevious =
            createdAt.isAfter(fourteenDaysAgo) &&
            createdAt.isBefore(sevenDaysAgo);

        if (inRecent) {
          newUsers++;
          if (roles.contains('mentee')) recentMentees++;
          if (roles.contains('mentor')) recentMentors++;
        } else if (inPrevious) {
          previousNewUsers++;
          if (roles.contains('mentee')) previousMentees++;
          if (roles.contains('mentor')) previousMentors++;
        }
      }

      // Calculate percentage changes
      final menteesChange = _calculatePercentageChange(
        recentMentees,
        previousMentees,
      );
      final mentorsChange = _calculatePercentageChange(
        recentMentors,
        previousMentors,
      );
      final newUsersChange = _calculatePercentageChange(
        newUsers,
        previousNewUsers,
      );

      return {
        'total_mentees': totalMentees,
        'total_mentors': totalMentors,
        'new_users': newUsers,
        'mentees_change': menteesChange,
        'mentors_change': mentorsChange,
        'new_users_change': newUsersChange,
      };
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching admin dashboard stats: $e');
      // Return zeros on error
      return {
        'total_mentees': 0,
        'total_mentors': 0,
        'new_users': 0,
        'mentees_change': 0.0,
        'mentors_change': 0.0,
        'new_users_change': 0.0,
      };
    }
  }

  /// Calculates percentage change between current and previous values.
  ///
  /// Returns the percentage change as a double.
  /// Positive values indicate growth, negative values indicate decline.
  /// Returns 0.0 if previous value is 0 (to avoid division by zero).
  double _calculatePercentageChange(int current, int previous) {
    if (previous == 0) {
      // If there were no users before, any new users represent infinite growth
      // We'll return 100% if there are new users, 0% if there are still none
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100;
  }

  /// Retrieves user growth data for the last 7 days for chart visualization.
  ///
  /// Returns a Map with daily counts:
  /// - 'dates': List of date strings (e.g., ['Nov 12', 'Nov 13', ...])
  /// - 'mentees': List of daily mentee counts
  /// - 'mentors': List of daily mentor counts
  ///
  /// Used by the admin dashboard to display growth trends.
  Future<Map<String, List<dynamic>>> getUserGrowthChartData() async {
    try {
      final List<String> dates = [];
      final List<int> menteeCounts = [];
      final List<int> mentorCounts = [];

      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Fetch users touched in the last 7 days by created_at OR updated_at
      final createdQuery = _db
          .collection(_usersCollection)
          .where(
            'created_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
          )
          .get();
      final updatedQuery = _db
          .collection(_usersCollection)
          .where(
            'updated_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
          )
          .get();
      final results = await Future.wait([createdQuery, updatedQuery]);
      final Map<String, Map<String, dynamic>> docsById = {};
      for (final snap in results) {
        for (final doc in snap.docs) {
          docsById[doc.id] = doc.data();
        }
      }

      // Get data for the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        // Format date for display (e.g., "Nov 12")
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        dates.add('${months[date.month - 1]} ${date.day}');

        // Count mentees and mentors created on this day
        int menteeCount = 0;
        int mentorCount = 0;

        for (var data in docsById.values) {
          final ts = data['created_at'] ?? data['updated_at'];
          if (ts == null || ts is! Timestamp) continue;
          final createdAt = ts.toDate();
          final roles = data['roles'] as List<dynamic>?;

          // Check if user was created on this day: [startOfDay, endOfDay)
          final inThisDay =
              (createdAt.isAtSameMomentAs(startOfDay) ||
                  createdAt.isAfter(startOfDay)) &&
              createdAt.isBefore(endOfDay);
          if (inThisDay && roles != null) {
            if (roles.contains('mentee')) {
              menteeCount++;
            }
            if (roles.contains('mentor')) {
              mentorCount++;
            }
          }
        }

        menteeCounts.add(menteeCount);
        mentorCounts.add(mentorCount);
      }

      return {'dates': dates, 'mentees': menteeCounts, 'mentors': mentorCounts};
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user growth chart data: $e');
      // Return empty data on error
      return {'dates': [], 'mentees': [], 'mentors': []};
    }
  }

  // ========== ADMIN NOTIFICATIONS ==========

  /// Stream admin notifications for a specific admin user
  ///
  /// Returns a stream of unread notifications ordered by creation time (newest first)
  /// [adminId] - The UID of the admin user
  /// [limit] - Maximum number of notifications to return (default: 10)
  ///
  /// IMPORTANT: This query requires a composite index in Firestore:
  /// Collection: notifications
  /// Fields: user_id (Ascending), is_read (Ascending), created_at (Descending)
  ///
  /// If you see an error, click the link in the error message to auto-create the index,
  /// or manually create it in Firebase Console > Firestore > Indexes
  Stream<List<NotificationModel>> streamAdminNotifications(
    String adminId, {
    int limit = 10,
  }) {
    return _db
        .collection(_notificationsCollection)
        .where('user_id', isEqualTo: adminId)
        .where('is_read', isEqualTo: false)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Mark a notification as read
  ///
  /// [notificationId] - The ID of the notification document to mark as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection(_notificationsCollection).doc(notificationId).update({
      'is_read': true,
    });
  }

  /// Create a new notification
  ///
  /// [userId] - The admin user ID to receive the notification
  /// [message] - The notification message
  /// [type] - The notification type (e.g., 'dispute', 'verification', 'payment')
  /// [contractId] - Optional contract ID related to the notification
  Future<void> createNotification({
    required String userId,
    required String message,
    required String type,
    String? contractId,
  }) async {
    final notification = NotificationModel(
      userId: userId,
      message: message,
      type: type,
      contractId: contractId,
      createdAt: Timestamp.now(),
      isRead: false,
    );

    await _db
        .collection(_notificationsCollection)
        .add(notification.toFirestore());
  }

  // ========== RECENT ACTIVITIES ==========

  /// Stream recent system activities
  ///
  /// Returns a stream of recent activities ordered by creation time (newest first)
  /// [limit] - Maximum number of activities to return (default: 50)
  ///
  /// IMPORTANT: This query requires an index in Firestore:
  /// Collection: activities
  /// Field: created_at (Descending)
  ///
  /// If you see an error, click the link in the error message to auto-create the index,
  /// or manually create it in Firebase Console > Firestore > Indexes
  Stream<List<ActivityModel>> streamRecentActivities({int limit = 50}) {
    return _db
        .collection(_activitiesCollection)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Create a new activity log entry
  ///
  /// [eventType] - The type of event (e.g., 'user_registered', 'mentor_approved')
  /// [description] - A description of the activity
  /// [relatedUserId] - Optional UID of the user involved in the activity
  Future<void> createActivity({
    required String eventType,
    required String description,
    String? relatedUserId,
  }) async {
    final activity = ActivityModel(
      eventType: eventType,
      description: description,
      relatedUserId: relatedUserId,
      createdAt: Timestamp.now(),
    );

    await _db.collection(_activitiesCollection).add(activity.toFirestore());
  }

  /// Seed sample notifications and activities for quick testing (DEV only)
  ///
  /// Inserts a small set of documents using snake_case fields with varying
  /// created_at timestamps to exercise ordering and relative-time UI.
  ///
  /// Note: This method is intended for development/testing and should not be
  /// exposed in production UI.
  Future<void> seedSampleData(String adminId) async {
    final now = DateTime.now();

    // Prepare sample notifications (unread)
    final notificationTimes = <DateTime>[
      now,
      now.subtract(const Duration(minutes: 7)),
      now.subtract(const Duration(hours: 2)),
      now.subtract(const Duration(days: 1)),
      now.subtract(const Duration(days: 3)),
    ];

    final notificationPayloads = <Map<String, dynamic>>[
      {
        'user_id': adminId,
        'message':
            'New mentor verification received. Please review the documents.',
        'type': 'verification',
        'contract_id': null,
        'is_read': false,
      },
      {
        'user_id': adminId,
        'message': 'Dispute opened on Contract #A1B2C3. Action required.',
        'type': 'dispute',
        'contract_id': 'A1B2C3',
        'is_read': false,
      },
      {
        'user_id': adminId,
        'message': 'Payment completed for Contract #X9Z8Y7.',
        'type': 'payment',
        'contract_id': 'X9Z8Y7',
        'is_read': false,
      },
      {
        'user_id': adminId,
        'message': 'New mentor verification received from Jane Smith.',
        'type': 'verification',
        'contract_id': null,
        'is_read': false,
      },
      {
        'user_id': adminId,
        'message': 'Dispute closed for Contract #A1B2C3.',
        'type': 'dispute',
        'contract_id': 'A1B2C3',
        'is_read': false,
      },
    ];

    // Prepare sample activities
    final activityTimes = <DateTime>[
      now,
      now.subtract(const Duration(minutes: 3)),
      now.subtract(const Duration(hours: 1, minutes: 15)),
      now.subtract(const Duration(days: 1, hours: 4)),
      now.subtract(const Duration(days: 5)),
      now.subtract(const Duration(days: 10)),
    ];

    final activityPayloads = <Map<String, dynamic>>[
      {
        'event_type': 'user_registered',
        'description': 'New user signed up: john.doe@example.com',
        'related_user_id': 'user_john',
      },
      {
        'event_type': 'mentor_approved',
        'description': 'Mentor profile approved: Jane Smith',
        'related_user_id': 'mentor_jane',
      },
      {
        'event_type': 'contract_created',
        'description': 'New contract created: #X9Z8Y7',
        'related_user_id': null,
      },
      {
        'event_type': 'payment_completed',
        'description': 'Payment captured for contract #X9Z8Y7',
        'related_user_id': null,
      },
      {
        'event_type': 'dispute_opened',
        'description': 'Dispute opened by user user_alex on #A1B2C3',
        'related_user_id': 'user_alex',
      },
      {
        'event_type': 'user_registered',
        'description': 'New user signed up: maria.lee@example.com',
        'related_user_id': 'user_maria',
      },
    ];

    final WriteBatch batch = _db.batch();

    // Queue notifications
    for (var i = 0; i < notificationPayloads.length; i++) {
      final payload = Map<String, dynamic>.from(notificationPayloads[i]);
      payload['created_at'] = Timestamp.fromDate(notificationTimes[i]);
      final ref = _db.collection(_notificationsCollection).doc();
      batch.set(ref, payload);
    }

    // Queue activities
    for (var i = 0; i < activityPayloads.length; i++) {
      final payload = Map<String, dynamic>.from(activityPayloads[i]);
      payload['created_at'] = Timestamp.fromDate(activityTimes[i]);
      final ref = _db.collection(_activitiesCollection).doc();
      batch.set(ref, payload);
    }

    await batch.commit();
  }

  // ========== USER MANAGEMENT ==========

  /// Get all users for admin user management
  ///
  /// Returns a list of all UserModel documents from the users collection
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _db.collection(_usersCollection).get();
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching all users: $e');
      return [];
    }
  }
}
