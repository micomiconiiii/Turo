import 'package:flutter/material.dart';
import 'package:user_home_page/core/data/models/mentor_profile.dart';
import 'package:user_home_page/core/data/services/matching_data_service.dart';
import 'widgets/profile_detail_card.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MatchingDataService _matchingService = MatchingDataService();
  late Future<List<MentorProfile>> _mentorsFuture;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _mentorsFuture = _matchingService.getSuggestedMatches('mentee123');
  }

  /// Builds the top "hero" image with gradient and name/chips overlay.
  Widget _buildHeader(MentorProfile mentor) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          // hero image
          SizedBox(
            height: 320,
            width: double.infinity,
            child: Image.asset(
              mentor.profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey),
            ),
          ),

          // dark gradient so text is readable
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.45),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),

          // top app bar row (TURO + icons)
          const Positioned(
            top: 18,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TURO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.notifications_none,
                        color: Colors.white, size: 26),
                    SizedBox(width: 12),
                    Icon(Icons.account_circle, color: Colors.white, size: 26),
                  ],
                ),
              ],
            ),
          ),

          // bottom name + chips
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentor.name,
                  style: AppTheme.montserratName,
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
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MentorProfile>>(
        future: _mentorsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mentors = snapshot.data!;
          return PageView.builder(
            controller: _pageController,
            itemCount: mentors.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final mentor = mentors[index];

              // Entire page is a rounded elevated Card — this ensures the image and details
              // are visually contained together and the details scroll independently.
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // header image (clipped by card)
                      _buildHeader(mentor),

                      // details area (scrollable)
                      Expanded(
                        child: ProfileDetailCard(mentor: mentor),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Sessions'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'Saved'),
        ],
      ),
    );
  }
}
