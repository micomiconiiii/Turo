// For Mentor Home Page
import 'package:flutter/material.dart';
import 'package:user_home_page/core/data/models/mentor_profile.dart';
import 'package:user_home_page/theme/mentor_app_theme.dart';

const Color _kDarkGreyText = Color(0xFF3D3D3D);

class ProfileDetailCard extends StatelessWidget {
  final MentorProfile mentor;

  const ProfileDetailCard({super.key, required this.mentor});

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
        style: AppTheme.montserratChip.copyWith(
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
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
          _buildSectionTitle("I'm looking for"),
          Wrap(
            children: mentor.lookingFor.map((e) => _buildChip(e)).toList(),
          ),
          _buildSectionDivider(),
          _buildSectionTitle('My budget is: '),
          Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 8),
            child: Text(
              mentor.budget,
              style: AppTheme.montserratChip.copyWith(
                color: _kDarkGreyText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          _buildSectionDivider(),
          _buildSectionTitle('Goals'),
          Wrap(
            children: mentor.goals.map((e) => _buildChip(e)).toList(),
          ),
          _buildSectionDivider(),
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
