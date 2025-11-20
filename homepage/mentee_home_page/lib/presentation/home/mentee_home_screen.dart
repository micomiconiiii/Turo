// For the Mentee Home Screen with swipeable mentor profiles
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:mentee_home_page/core/data/models/mentor_profile.dart';
import 'package:mentee_home_page/core/data/services/mentor_matching_data_service.dart';
import 'package:mentee_home_page/presentation/home/widgets/mentee_profile_detail_card.dart';
import 'package:mentee_home_page/presentation/home/widgets/bottom_nav_bar.dart';
import 'package:mentee_home_page/theme/mentee_app_theme.dart';

const double _kBottomNavBarHeight = 130.0;

class MenteeHomeScreen extends StatefulWidget {
  const MenteeHomeScreen({super.key});

  @override
  State<MenteeHomeScreen> createState() => _MenteeHomeScreenState();
}

class _MenteeHomeScreenState extends State<MenteeHomeScreen> {
  final MenteeMatchingDataService _matchingService =
      MenteeMatchingDataService();
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

    _swipeItems.clear();
    for (var mentor in mentors) {
      _swipeItems.add(SwipeItem(
        content: mentor,
        likeAction: () => _onSwipe(mentor, true),
        nopeAction: () => _onSwipe(mentor, false),
      ));
    }

    setState(() {
      _mentors = mentors;
      _isLoading = false;
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  void _onSwipe(MentorProfile mentor, bool liked) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          liked ? 'You liked ${mentor.name}' : 'You skipped ${mentor.name}'),
      duration: const Duration(milliseconds: 700),
    ));
  }

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
                Row(
                  children: [
                    if (mentor.isVerified) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Verified',
                          // Fustat Regular 12
                          style: TextStyle(
                            fontFamily: 'Fustat',
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFF047857), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            mentor.rating,
                            style: const TextStyle(
                              fontFamily: 'Fustat',
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: AppTheme.montserratName,
                    children: [
                      TextSpan(text: mentor.name.toUpperCase()),
                      TextSpan(
                        text: ', ${mentor.age}',
                        style: const TextStyle(
                          fontFamily: 'Fustat',
                          fontWeight: FontWeight.w400, // Regular
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        style: AppTheme.montserratBody.copyWith(
                          color: Colors.white,
                        ),
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
