// file: home_screen.dart
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:user_home_page/core/data/models/mentor_profile.dart';
import 'package:user_home_page/core/data/services/matching_data_service.dart';
import 'package:user_home_page/presentation/home/widgets/profile_detail_card.dart';
import 'package:user_home_page/theme/app_theme.dart';

// Define a reasonable height for the bottom navigation bar area
const double _kBottomNavBarHeight = 80.0;

class HomeScreen extends StatefulWidget {
// ... (HomeScreen and _HomeScreenState definitions remain the same)
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MatchingDataService _matchingService = MatchingDataService();
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  List<MentorProfile> _mentors = [];
  bool _isLoading = true;

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

  // _buildHeader remains the same as previous response

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
                      child: Text(e,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
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

  // FIX: Use ListView to make the entire card scrollable.
  Widget _buildCard(MentorProfile mentor) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        // IMPORTANT: No padding here. The padding for the bottom bar is handled
        // by the parent Positioned widget in the build method.
        padding: EdgeInsets.zero,
        children: [
          // Header (Image, Name, Expertise)
          _buildHeader(mentor),
          // Details
          ProfileDetailCard(mentor: mentor),
        ],
      ),
    );
  }

  // _buildAppBar remains the same as previous response

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
        color: Colors.transparent,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TURO',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
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

    // We will assume the full screen height (MediaQuerry.size.height) and subtract the bottom bar height
    // Or, more simply, use the 'bottom' property of Positioned.fill.

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mentors.isEmpty
              ? const Center(child: Text('No more mentors available.'))
              : Stack(
                  children: [
                    // 1. Swipe Cards - Define fixed top and bottom boundaries.
                    Positioned.fill(
                      top: headerHeight,
                      // FIX HERE: Set a fixed bottom padding to reserve space for the bottom nav bar.
                      // The cards will now end here instead of filling the whole screen.
                      bottom: _kBottomNavBarHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SwipeCards(
                          matchEngine: _matchEngine,
                          itemBuilder: (BuildContext context, int index) {
                            final mentor = _mentors[index];
                            return _buildCard(mentor);
                          },
                          onStackFinished: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'You’ve reached the end of the list!')),
                            );
                          },
                          upSwipeAllowed: false,
                          fillSpace: true,
                        ),
                      ),
                    ),
                    // 2. The App Bar (layered on top)
                    _buildAppBar(),

                    // 3. Placeholder for Bottom Navigation Bar (Optional, for visual alignment)
                    // You will replace this with your actual BottomNavigationBar later.
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: _kBottomNavBarHeight,
                      child: Container(
                        color: Colors
                            .white, // Use your actual nav bar background color
                        child: Center(
                          child: Text(
                              'Bottom Nav Bar Area (${_kBottomNavBarHeight.toInt()}px)',
                              style: const TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
