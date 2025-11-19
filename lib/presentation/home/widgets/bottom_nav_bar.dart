import 'package:flutter/material.dart';
import 'package:user_home_page/theme/mentor_app_theme.dart';

class TuroBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const TuroBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Floating Navbar Styling
      height: 80,
      margin: const EdgeInsets.only(
          left: 24, right: 24, bottom: 34), // Pushes it off the edges
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary, // Dark green
        borderRadius: BorderRadius.circular(40), // Fully rounded pill shape
        boxShadow: [
          BoxShadow(
            // FIXED: Updated to use .withValues(alpha: ...)
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5), // Drop shadow for depth
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          return _buildNavItem(index);
        }),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    const icons = [
      Icons.home_rounded,
      Icons.calendar_month_rounded,
      Icons.group_rounded,
      Icons.messenger_outline_rounded,
      Icons.assignment_rounded,
    ];

    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Tighter padding to match the Figma design's active state circle
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icons[index],
          // Slightly smaller icon size for a cleaner look
          size: 26,
          color: isSelected ? AppTheme.primary : Colors.white,
        ),
      ),
    );
  }
}
