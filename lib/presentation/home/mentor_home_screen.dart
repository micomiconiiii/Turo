import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:user_home_page/presentation/home/widgets/bottom_nav_bar.dart';
import 'package:user_home_page/core/data/models/mentee_profile.dart';
import 'package:user_home_page/core/data/services/mentee_matching_data_service.dart';
import 'package:user_home_page/theme/mentor_app_theme.dart';

const double _kBottomNavBarHeight = 130.0;

class MentorHomeScreen extends StatefulWidget {
  const MentorHomeScreen({super.key});

  @override
  State<MentorHomeScreen> createState() => _MentorHomeScreenState();
}

class _MentorHomeScreenState extends State<MentorHomeScreen> {
  final MenteeMatchingDataService _matchingService =
      MenteeMatchingDataService();
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;

  List<MenteeProfile> _mentees = [];
  bool _isLoading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    final mentees =
        await _matchingService.getSuggestedMentees('mentor_id_placeholder');

    setState(() {
      _mentees = mentees;
      _isLoading = false;
    });

    _swipeItems.clear();
    for (var mentee in mentees) {
      _swipeItems.add(
        SwipeItem(
          content: mentee,
          likeAction: () => _onSwipe(mentee, true),
          nopeAction: () => _onSwipe(mentee, false),
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  void _onSwipe(MenteeProfile mentee, bool liked) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(liked
            ? 'You accepted ${mentee.fullName}'
            : 'You skipped ${mentee.fullName}'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  /// ---------- UI BUILDERS ----------

  Widget _buildHeader(MenteeProfile mentee) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          // 1. IMAGE
          SizedBox(
            height: 320,
            width: double.infinity,
            child: mentee.profileImageUrl.startsWith('http')
                ? Image.network(
                    mentee.profileImageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter, // Aligns face to top
                  )
                : Image.asset(
                    mentee.profileImageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
          ),

          // 2. GRADIENT OVERLAY
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),

          // 3. NAME & OVERLAY SKILLS
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mentee.fullName.toUpperCase(),
                  style: AppTheme.montserratName,
                ),
                const SizedBox(height: 8),

                // HEADER CHIPS (Same Green as Body Chips)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: mentee.skillsToLearn.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.chipGreen, // #2C6A64
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        skill,
                        style: AppTheme.montserratChip,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenteeDetails(MenteeProfile mentee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // --- About ---
          _buildSectionTitle('About'),
          Text(
            mentee.bio,
            style: AppTheme.montserratBody, // Regular, Size 15
          ),
          _buildDivider(),

          // --- I'm looking for ---
          _buildSectionTitle("I'm looking for:"),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: mentee.targetMentors
                .map((role) => _buildBodyChip(role))
                .toList(),
          ),
          _buildDivider(),

          // --- Budget ---
          _buildSectionTitle('My budget is:'),
          Text(
            mentee.budget,
            style: AppTheme.montserratBody.copyWith(
              color: AppTheme.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          _buildDivider(),

          // --- Goals ---
          _buildSectionTitle('Goals:'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: mentee.goals.map((g) => _buildBodyChip(g)).toList(),
          ),
          _buildDivider(),

          // --- Notes ---
          _buildSectionTitle('Notes:'),
          Text(
            mentee.notes,
            style: AppTheme.montserratBody,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Helper for Section Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
      child: Text(
        title,
        style: AppTheme.montserratSectionTitle, // SemiBold, Size 20
      ),
    );
  }

  /// Helper for the Chips inside the body area
  Widget _buildBodyChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        // 🟢 FIXED: Used AppTheme.chipGreen (#2C6A64) based on your Figma proof
        color: AppTheme.chipGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        // Using Fustat (body3) Size 12 as requested
        style: AppTheme.body3.copyWith(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(height: 1, thickness: 1, color: AppTheme.lightGrey),
    );
  }

  Widget _buildCard(MenteeProfile mentee) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      color: AppTheme.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(mentee),
          _buildMenteeDetails(mentee),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TURO',
              style: AppTheme.fustatHeader,
            ),
            Row(
              children: [
                Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        color: AppTheme.black, size: 28),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.alert,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 12),
                const Icon(Icons.account_circle_rounded,
                    color: AppTheme.black, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- MAIN BUILD ----------

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).padding.top + 50;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mentees.isEmpty
              ? const Center(child: Text('No more mentees available.'))
              : Stack(
                  children: [
                    Positioned.fill(
                      top: headerHeight,
                      bottom: _kBottomNavBarHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SwipeCards(
                          matchEngine: _matchEngine,
                          itemBuilder: (context, index) {
                            return _buildCard(_mentees[index]);
                          },
                          onStackFinished: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('You’ve reached the end of the list!'),
                              ),
                            );
                          },
                          upSwipeAllowed: false,
                          fillSpace: true,
                        ),
                      ),
                    ),
                    _buildAppBar(),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: TuroBottomNavBar(
                        selectedIndex: _navIndex,
                        onTap: (i) {
                          setState(() => _navIndex = i);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
