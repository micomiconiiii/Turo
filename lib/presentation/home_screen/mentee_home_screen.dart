import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/services/mentee_matching_data_service.dart';
import 'package:turo/widgets/bottom_nav_bar.dart';
import 'package:turo/theme/mentor_app_theme.dart';

const double _kBottomNavBarHeight = 130.0;

class MenteeHomeScreen extends StatefulWidget {
  const MenteeHomeScreen({super.key});

  @override
  State<MenteeHomeScreen> createState() => _MenteeHomeScreenState();
}

class _MenteeHomeScreenState extends State<MenteeHomeScreen> {
  final MenteeMatchingDataService _matchingService = MenteeMatchingDataService();
  final List<SwipeItem> _swipeItems = [];
  MatchEngine? _matchEngine;
  List<UserModel> _suggestedMentors = [];
  bool _isLoading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to see mentors.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      // As per instructions, assuming getSuggestedMentors exists.
      final mentors = await _matchingService.getSuggestedMentors(user.uid);

      if (!mounted) return;

      setState(() {
        _suggestedMentors = mentors;
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

        if (_swipeItems.isNotEmpty) {
          _matchEngine = MatchEngine(swipeItems: _swipeItems);
        }

        _isLoading = false;
      });
    } catch (e) {
      print("Error loading mentors: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading mentors: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSwipe(UserModel mentor, bool liked) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // A mentee is swiping on a mentor
      _matchingService.recordSwipe(
        menteeId: user.uid,
        mentorId: mentor.userId,
        isLike: liked,
      );
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(liked
            ? 'You liked ${mentor.displayName}'
            : 'You skipped ${mentor.displayName}'),
        duration: const Duration(milliseconds: 500),
        backgroundColor: liked ? AppTheme.chipGreen : Colors.grey,
      ),
    );
  }

  // --- DATA EXTRACTION HELPERS ---

  String _getMentorField(UserModel mentor, String key, [String defaultValue = 'N/A']) {
    return mentor.mentorProfile?[key]?.toString() ?? defaultValue;
  }

  List<String> _getMentorSkills(UserModel mentor) {
    final skills = mentor.mentorProfile?['skills'] ?? mentor.mentorProfile?['expertise'];
    if (skills is List) {
      return skills.map((s) => s.toString()).toList();
    }
    return [];
  }

  // --- UI WIDGETS ---

  Widget _buildHeader(UserModel mentor) {
    final String? imageUrl = mentor.profilePictureUrl;
    final bool hasValidUrl = imageUrl != null && imageUrl.isNotEmpty;
    final bool isNetworkImage = hasValidUrl && imageUrl.startsWith('http');
    
    final String jobTitle = _getMentorField(mentor, 'job_title', 'Job Title Not Available');
    final String company = _getMentorField(mentor, 'company', 'Company Not Available');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          SizedBox(
            height: 320,
            width: double.infinity,
            child: hasValidUrl
                ? (isNetworkImage
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 60)),
                      )
                    : Image.asset(imageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter))
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
          ),
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x99000000)],
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        mentor.displayName.toUpperCase(),
                        style: AppTheme.montserratName.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Display a verified badge if the mentor's 'isVerified' flag is true.
                    if (mentor.isVerified == true) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Colors.blueAccent, size: 24),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                 Text(
                  '$jobTitle at $company',
                  style: AppTheme.montserratBody.copyWith(color: Colors.white.withOpacity(0.9)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorDetails(UserModel mentor) {
    final String hourlyRate = _getMentorField(mentor, 'hourly_rate', 'N/A');
    final String experience = _getMentorField(mentor, 'years_of_experience', 'N/A');
    final List<String> skills = _getMentorSkills(mentor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle('About'),
          Text(mentor.bio, style: AppTheme.montserratBody),
          _buildDivider(),

          // Experience and Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      _buildSectionTitle("Experience"),
                      Row(
                        children: [
                          const Icon(Icons.work_history_outlined, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '$experience years',
                            style: AppTheme.montserratBody.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                   ],
                 ),
               ),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      _buildSectionTitle('Hourly Rate'),
                      Text(
                        // Directly access mentor profile data, which was fetched from Firestore
                        '\$${mentor.mentorProfile?['hourly_rate']?.toString() ?? 'N/A'} / hr',
                        style: AppTheme.montserratBody.copyWith(fontWeight: FontWeight.w600),
                      ),
                   ],
                 ),
               )
            ],
          ),
          _buildDivider(),

          // Skills
          _buildSectionTitle('Skills & Expertise'),
          if (skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => _buildBodyChip(skill)).toList(),
            )
          else
            Text('No skills listed.', style: AppTheme.montserratBody),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  // Helper Widgets from MentorHomeScreen for consistent styling
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
      child: Text(
        title,
        style: AppTheme.montserratSectionTitle.copyWith(color: Colors.black, fontSize: 18),
      ),
    );
  }

  Widget _buildBodyChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(height: 1, thickness: 1, color: AppTheme.lightGrey),
    );
  }

  Widget _buildCard(UserModel mentor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(mentor),
          _buildMentorDetails(mentor),
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
            const Text('TURO', style: AppTheme.fustatHeader),
            Row(
              children: [
                // Actions can be added here later
                const Icon(Icons.filter_list, color: Colors.black, size: 28),
                const SizedBox(width: 12),
                const Icon(Icons.account_circle_rounded, color: Colors.black, size: 28),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            top: headerHeight,
            bottom: _kBottomNavBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _suggestedMentors.isEmpty || _matchEngine == null
                      ? Center(
                          child: Text(
                            'No mentors available right now.\nCheck back later!',
                            textAlign: TextAlign.center,
                            style: AppTheme.montserratBody.copyWith(color: Colors.grey),
                          ),
                        )
                      : SwipeCards(
                          matchEngine: _matchEngine!,
                          itemBuilder: (context, index) {
                            return _buildCard(_suggestedMentors[index]);
                          },
                          onStackFinished: () {
                             setState(() {
                              // To make the "No more mentors" message appear
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("That's all for now!")),
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
              onTap: (i) => setState(() => _navIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}
