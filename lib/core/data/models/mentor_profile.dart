import 'package:flutter/material.dart';

/// Central color definitions shared across the app
class AppColors {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color darkGray = Color(0xFF4B5563);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color deepGreen = Color(0xFF047857);
}

/// Model representing a mentor’s data
class MentorProfile {
  final String id;
  final String name;
  final String tagline;
  final String about;
  final List<String> expertise;
  final String profileImageUrl;
  final List<String> lookingFor;
  final String budget;
  final List<String> goals;
  final String notes;

  const MentorProfile({
    required this.id,
    required this.name,
    required this.tagline,
    required this.about,
    required this.expertise,
    required this.profileImageUrl,
    required this.lookingFor,
    required this.budget,
    required this.goals,
    required this.notes,
  });
}
