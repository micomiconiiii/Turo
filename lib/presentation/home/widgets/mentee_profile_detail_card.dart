// For Mentee Home Page
import 'package:flutter/material.dart';
import 'package:mentee_home_page/core/data/models/mentor_profile.dart';
import 'package:mentee_home_page/theme/mentee_app_theme.dart';

class ProfileDetailCard extends StatelessWidget {
  final MentorProfile mentor;

  const ProfileDetailCard({super.key, required this.mentor});

  List<Map<String, String>> get _sampleExperience => [
        {
          'title': 'Senior Developer',
          'company': 'Microsoft',
          'years': '2015 - 2025',
        },
        {
          'title': 'Junior System Analyst',
          'company': 'Microsoft',
          'years': '2011 - 2015',
        },
      ];

  List<String> get _sampleTopics => ['Web Development', 'Data'];

  List<String> get _sampleBenefits =>
      ['Unlimited Chats', 'Flexible time', 'Excellent Work Ethic'];

  Widget _chip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.chipGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTheme.body3.copyWith(color: AppTheme.white),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      child: Text(
        title,
        style: AppTheme.montserratSectionTitle,
      ),
    );
  }

  Widget _divider() {
    return const Column(
      children: [
        SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: AppTheme.lightGrey),
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
          const SizedBox(height: 14),
          _sectionTitle('About'),
          Text(
            mentor.about,
            style: AppTheme.montserratBody,
          ),
          _divider(),
          _sectionTitle("We'll match if you're a:"),
          Wrap(
            children: mentor.lookingFor.map((e) => _chip(e)).toList(),
          ),
          _divider(),
          _sectionTitle('Experience'),
          Column(
            children: _sampleExperience.map((exp) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 14,
                      width: 14,
                      decoration: const BoxDecoration(
                        color: AppTheme.chipGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp['title'] ?? '', style: AppTheme.body3),
                          const SizedBox(height: 2),
                          Text(exp['company'] ?? '',
                              style: AppTheme.body3
                                  .copyWith(color: AppTheme.secondary)),
                        ],
                      ),
                    ),
                    Text(exp['years'] ?? '',
                        style:
                            AppTheme.body3.copyWith(color: AppTheme.secondary)),
                  ],
                ),
              );
            }).toList(),
          ),
          _divider(),
          _sectionTitle('Topics'),
          Wrap(
            children: _sampleTopics.map((t) => _chip(t)).toList(),
          ),
          const SizedBox(height: 10),
          _divider(),
          _sectionTitle('My rate is:'),
          Text(
            mentor.budget,
            style:
                AppTheme.montserratBody.copyWith(fontWeight: FontWeight.w600),
          ),
          _divider(),
          _sectionTitle('Goals:'),
          Wrap(children: mentor.goals.map((g) => _chip(g)).toList()),
          _divider(),
          _sectionTitle('Benefits'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _sampleBenefits
                .map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("• $benefit", style: AppTheme.montserratBody),
                    ))
                .toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
