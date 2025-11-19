import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:user_home_page/core/data/models/mentor_profile.dart';
import 'package:user_home_page/core/data/services/mentor_matching_data_service.dart';
import 'package:user_home_page/presentation/home/widgets/mentor_profile_detail_card.dart';
import 'package:user_home_page/theme/mentor_app_theme.dart';
import 'package:user_home_page/presentation/home/widgets/bottom_nav_bar.dart';

// Increased height reserved for navbar (Height 80 + Margin 34 + Buffer)
const double _kBottomNavBarHeight = 130.0;

class MentorHomeScreen extends StatefulWidget {
  const MentorHomeScreen({super.key});

  @override
  State<MentorHomeScreen> createState() => _MentorHomeScreenState();
}

class _MentorHomeScreenState extends State<MentorHomeScreen> {
  final MatchingDataService _matchingService = MatchingDataService();
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;

  List<MentorProfile> _mentors = [];
  bool _isLoading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    final mentors = await _matchingService.getSuggestedMatches('mentee123');

    setState(() {
      _mentors = mentors;
      _isLoading = false;
    });

    _swipeItems.clear();
    for (var mentor in mentors) {
      _swipeItems.add(
        SwipeItem(
          content: mentor,
          likeAction: () => _onSwipe(mentor, true),
          nopeAction: () => _onSwipe(mentor, false),
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  void _onSwipe(MentorProfile mentor, bool liked) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            liked ? 'You liked ${mentor.name}' : 'You skipped ${mentor.name}'),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  /// ---------- UI BUILDERS ----------

  Widget _buildHeader(MentorProfile mentor) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          SizedBox(
            height: 320,
            width: double.infinity,
            child: mentor.profileImageUrl.startsWith('http')
                ? Image.network(mentor.profileImageUrl, fit: BoxFit.cover)
                : Image.asset(mentor.profileImageUrl, fit: BoxFit.cover),
          ),
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x73000000)],
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mentor.name, style: AppTheme.montserratName),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: mentor.expertise.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.chipGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        e,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildCard(MentorProfile mentor) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(mentor),
          ProfileDetailCard(mentor: mentor),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TURO',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.notifications_none, color: Colors.black, size: 26),
                SizedBox(width: 12),
                Icon(Icons.account_circle, color: Colors.black, size: 26),
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
          : _mentors.isEmpty
              ? const Center(child: Text('No more mentors available.'))
              : Stack(
                  children: [
                    /// Swipe card area
                    Positioned.fill(
                      top: headerHeight,
                      bottom: _kBottomNavBarHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SwipeCards(
                          matchEngine: _matchEngine,
                          itemBuilder: (context, index) {
                            return _buildCard(_mentors[index]);
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

                    /// Top AppBar
                    _buildAppBar(),

                    /// Floating Bottom Navbar
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
