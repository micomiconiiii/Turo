import 'package:flutter/material.dart';

/// Admin Side Navigation Menu
///
/// A vertical sidebar that provides access to all admin panel sections.
/// Features a wider layout (280px) with icon + text rows for better readability.
class AdminSideMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AdminSideMenu({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF10403B), // Turo primary color
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
          // Header/Logo Section
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 24.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 8),
                const Text(
                  'TURO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Menu Items (Scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                _buildMenuItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                _buildMenuItem(
                  context,
                  index: 1,
                  icon: Icons.verified_user_outlined,
                  selectedIcon: Icons.verified_user,
                  label: 'Mentor Verification',
                ),
                _buildMenuItem(
                  context,
                  index: 2,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'User Management',
                ),
                _buildMenuItem(
                  context,
                  index: 3,
                  icon: Icons.description_outlined,
                  selectedIcon: Icons.description,
                  label: 'Contracts & Disputes',
                ),
                _buildMenuItem(
                  context,
                  index: 4,
                  icon: Icons.attach_money_outlined,
                  selectedIcon: Icons.attach_money,
                  label: 'Financials',
                ),
                _buildMenuItem(
                  context,
                  index: 5,
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  label: 'Reports',
                ),
                _buildMenuItem(
                  context,
                  index: 6,
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'Announcements',
                ),
                _buildMenuItem(
                  context,
                  index: 7,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
