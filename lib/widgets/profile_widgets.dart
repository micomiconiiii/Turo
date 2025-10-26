import 'package:flutter/material.dart';

/// A reusable chip widget for displaying items like availability days or skills.
class InfoChip extends StatelessWidget {
  final String label;
  final bool isFilled; // Determines background and text color
  final Color filledColor;
  // Removed borderColor parameter as we'll use Colors.grey directly
  final Color textColor;
  final Color filledTextColor;

  const InfoChip({
    super.key,
    required this.label,
    this.isFilled = false,
    this.filledColor = const Color(0xFF1B4D44), // Turo dark green
    // Removed borderColor initialization
    this.textColor = Colors.black87,
    this.filledTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 8), // Spacing around chip
      decoration: BoxDecoration(
        color: isFilled ? filledColor : Colors.transparent, // Conditional background
        borderRadius: BorderRadius.circular(20), // Rounded corners
        border: Border.all(
          // Use filled color for border if filled, otherwise use Colors.grey.shade400 directly
          color: isFilled ? filledColor : Colors.grey.shade400, // <--- FIXED HERE
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          // Conditional text color
          color: isFilled ? filledTextColor : textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---

/// A reusable card container for profile sections (Availability, Skills, Experience).
class ProfileSectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  final Widget child; // The content of the section (e.g., Wrap of chips, Column of items)
  final bool hasBorder; // Flag to add the blue border (for Skills section)
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;


  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.onAdd,
    required this.child,
    this.hasBorder = false,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        // Add subtle shadow
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        // Conditionally add the blue border
        border: hasBorder
            ? Border.all(
                color: Colors.blueAccent.withOpacity(0.5),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header (Title + Add Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // "Add+" Button
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0F2F1), // Light teal
                  foregroundColor: const Color(0xFF1B4D44), // Dark green
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // The main content passed to the card
          child,
        ],
      ),
    );
  }
}

// ---

/// A row widget representing an item in the Experience section.
class ExperienceItem extends StatelessWidget {
  final String title;
  final String company;
  final String dates;
  final Color avatarColor;

  const ExperienceItem({
    super.key,
    required this.title,
    required this.company,
    required this.dates,
    this.avatarColor = const Color(0xFF1B4D44), // Turo dark green default
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Space below each item
      child: Row(
        children: [
          // Placeholder Circle Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
          ),
          const SizedBox(width: 16),
          // Title and Company Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(company, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          // Dates Text
          Text(dates, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}