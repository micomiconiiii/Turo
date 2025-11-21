//For the backend data model of mentor Profile
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color darkGray = Color(0xFF4B5563);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color deepGreen = Color(0xFF047857);
}

class MentorProfile {
  final String id;
  final String name;
  final int age;
  final bool isVerified;
  final String rating;
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
    required this.age,
    required this.isVerified,
    required this.rating,
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
