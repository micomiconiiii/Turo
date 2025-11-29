import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:turo/services/admin_service.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/models/user_detail_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedRoleFilter = 'All'; // All, Mentor, Mentee
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Debug: Print current user's UID
    // Remove or comment out after troubleshooting
    // ignore: avoid_print
    print('Current UID: [32m${FirebaseAuth.instance.currentUser?.uid}[0m');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          _buildHeader(),
          const SizedBox(height: 32),

          // CONTROLS (Search & Filter)
          _buildControls(),
          const SizedBox(height: 24),

          // MAIN TABLE
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
                child: StreamBuilder<List<UserModel>>(
                  stream: _adminService.streamAllUsers(),
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

                    // 1. FILTERING LOGIC
                    final users = _filterUsers(snapshot.data!);

                    // 2. DATA TABLE
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
                          dataRowColor: MaterialStateProperty.all(Colors.white),
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
                            DataColumn(label: Text('USER')),
                            DataColumn(label: Text('ROLE')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('ACTIONS')),
                          ],
                          rows: users
                              .map((user) => _buildUserRow(user))
                              .toList(),
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
    );
  }

  // --- LOGIC: FILTERING ---
  List<UserModel> _filterUsers(List<UserModel> allUsers) {
    return allUsers.where((user) {
      // 1. Role Filter
      if (_selectedRoleFilter != 'All') {
        if (!user.roles.contains(_selectedRoleFilter.toLowerCase())) {
          return false;
        }
      }

      // 2. Search Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatches = user.displayName.toLowerCase().contains(query);
        return nameMatches;
      }

      return true;
    }).toList();
  }

  // --- WIDGETS: COMPONENTS ---

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10403B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.people_outline,
            color: Color(0xFF10403B),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Directory',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10403B),
              ),
            ),
            Text(
              'Manage mentors, mentees, and administrators.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF414480).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by display name...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              // FIX 1: Remove the hover color tint
              hoverColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Role Filter Chips
        _buildFilterChip('All'),
        const SizedBox(width: 8),
        _buildFilterChip('Mentor'),
        const SizedBox(width: 8),
        _buildFilterChip('Mentee'),
        const SizedBox(width: 8),
        _buildFilterChip('Admin'),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedRoleFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedRoleFilter = label);
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF10403B).withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF10403B) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF10403B) : Colors.grey.shade200,
      ),
    );
  }

  DataRow _buildUserRow(UserModel user) {
    // Determine Role Badge Color
    Color roleColor = Colors.blue;
    if (user.roles.contains('admin')) roleColor = Colors.purple;
    if (user.roles.contains('mentor')) roleColor = const Color(0xFF10403B);

    return DataRow(
      cells: [
        // 1. User Info (Avatar + Name)
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: user.profilePictureUrl != null
                    ? CachedNetworkImageProvider(user.profilePictureUrl!)
                    : null,
                child: user.profilePictureUrl == null
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    user.userId.substring(0, 8),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Role Badge
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: roleColor.withOpacity(0.2)),
            ),
            child: Text(
              user.roles.isNotEmpty ? user.roles.first.toUpperCase() : 'USER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),
        ),

        // 3. Status Cell (UPDATED: No more FutureBuilder!)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // We now read 'isActive' directly from the User Model
                  color: user.isActive ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.isActive ? 'Active' : 'Suspended',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),

        // 4. Actions (Three Dots)
        DataCell(
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () => _showUserDetails(context, user),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No users found."));
  }

  Widget _buildErrorState(Object? error) {
    return Center(child: Text("Error: $error"));
  }

  // --- DIALOG: VIEW DETAILS & SUSPEND ---
  void _showUserDetails(BuildContext context, UserModel user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    UserDetailModel? details = await _adminService.getUserDetails(user.userId);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not fetch user details.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        bool isActive = details!.isActive;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              // FIX 2: Force white background and remove tint
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Text(
                    "User Details",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem("Display Name", user.displayName),
                    const Divider(),
                    _buildDetailItem("Legal Name", details!.fullName),
                    const Divider(),
                    _buildDetailItem("Email", details.email),
                    const Divider(),
                    _buildDetailItem("Address", details.address),
                    const SizedBox(height: 24),

                    // SUSPEND TOGGLE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.block,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActive
                                      ? "Account Active"
                                      : "Account Suspended",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  isActive
                                      ? "User can login and use the app."
                                      : "User is banned from accessing the app.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            activeColor: Colors.green,
                            onChanged: (val) async {
                              // Optimistic Update
                              setStateDialog(() => isActive = val);

                              try {
                                await _adminService.toggleUserStatus(
                                  user.userId,
                                  !val,
                                );
                              } catch (e) {
                                // FIX: Check if context is valid before updating UI
                                if (context.mounted) {
                                  setStateDialog(
                                    () => isActive = !val,
                                  ); // Revert switch
                                }
                                print("Error toggling status: $e");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
