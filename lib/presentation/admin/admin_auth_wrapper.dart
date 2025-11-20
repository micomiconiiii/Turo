import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turo/services/database_service.dart';
import 'admin_main_view.dart';
import 'pages/admin_login_page.dart';

/// Admin Auth Wrapper
///
/// Checks authentication state and admin role before granting access.
/// - If not authenticated → AdminLoginPage
/// - If authenticated but not admin → AdminLoginPage (with error)
/// - If authenticated and admin → AdminMainView
class AdminAuthWrapper extends StatelessWidget {
  const AdminAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is not authenticated
        if (!snapshot.hasData || snapshot.data == null) {
          return const AdminLoginPage();
        }

        // User is authenticated - verify admin role
        return FutureBuilder<bool>(
          future: _checkAdminRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If not admin or error checking role, show login
            if (!roleSnapshot.hasData || !roleSnapshot.data!) {
              // Sign out non-admin users
              FirebaseAuth.instance.signOut();
              return const AdminLoginPage();
            }

            // User is authenticated and is admin
            return const AdminMainView();
          },
        );
      },
    );
  }

  Future<bool> _checkAdminRole(String uid) async {
    try {
      final databaseService = DatabaseService();
      final userDoc = await databaseService.getUser(uid);

      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      final roles = userData?['roles'] as List<dynamic>?;

      return roles != null && roles.contains('admin');
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }
}
