import 'package:flutter/material.dart';
import 'package:user_home_page/core/data/models/mentor_profile.dart';
import 'package:user_home_page/theme/app_theme.dart';

class ProfileDetailCard extends StatelessWidget {
  final MentorProfile mentor;

  const ProfileDetailCard({super.key, required this.mentor});

  Widget _buildChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.chipGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTheme.body3.copyWith(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About'),
          Text(
            mentor.about,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppTheme.secondary,
            ),
          ),
          _buildSectionTitle("I'm looking for"),
          Wrap(
            children: mentor.lookingFor.map((e) => _buildChip(e)).toList(),
          ),
          _buildSectionTitle('My budget'),
          _buildChip(mentor.budget),
          _buildSectionTitle('Goals'),
          Wrap(
            children: mentor.goals.map((e) => _buildChip(e)).toList(),
          ),
          _buildSectionTitle('Notes'),
          Text(
            mentor.notes,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
