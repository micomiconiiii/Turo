import 'package:flutter/material.dart';
import 'package:user_home_page/core/data/models/mentor_profile.dart';
import 'package:user_home_page/theme/app_theme.dart';

// Define the custom color for the text: Black (Hex #3D3D3D)
const Color _kDarkGreyText = Color(0xFF3D3D3D);

class ProfileDetailCard extends StatelessWidget {
  final MentorProfile mentor;

  const ProfileDetailCard({super.key, required this.mentor});

  // --- Helper Widgets ---

  Widget _buildChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 4),
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
      padding: const EdgeInsets.only(top: 16.0, bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          // FIX: Updated color to Black (3D3D3D)
          color: _kDarkGreyText,
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return const Column(
      children: [
        SizedBox(height: 18),
        Divider(
          height: 1,
          thickness: 1,
          color: AppTheme.lightGrey,
        ),
        SizedBox(height: 8),
      ],
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content for the 'About' section
          const SizedBox(height: 15),
          // Title color updated
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

          _buildSectionDivider(),

          // Content for the 'I'm looking for' section
          // Title color updated
          _buildSectionTitle("I'm looking for"),
          Wrap(
            children: mentor.lookingFor.map((e) => _buildChip(e)).toList(),
          ),

          _buildSectionDivider(),

          // Content for the 'My budget is' section
          // Title color updated
          _buildSectionTitle('My budget is: '),
          Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 8),
            child: Text(
              mentor.budget, // This is the price (e.g., PHP200/hr)
              style: AppTheme.body3.copyWith(
                // FIX: Updated color to Black (3D3D3D)
                color: _kDarkGreyText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          _buildSectionDivider(),

          // Content for the 'Goals' section
          // Title color updated
          _buildSectionTitle('Goals'),
          Wrap(
            children: mentor.goals.map((e) => _buildChip(e)).toList(),
          ),

          _buildSectionDivider(),

          // Content for the 'Notes' section
          // Title color updated
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
