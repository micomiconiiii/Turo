import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:turo/widgets/bottom_nav_bar.dart'; 
import 'package:turo/services/mentee_matching_data_service.dart';
import 'package:turo/theme/mentor_app_theme.dart';
import 'package:turo/models/user_model.dart';
import 'package:turo/presentation/match_screen/match_screen.dart'; 

const double _kBottomNavBarHeight = 130.0;

class MentorHomeScreen extends StatefulWidget {
  const MentorHomeScreen({super.key});

  @override
  State<MentorHomeScreen> createState() => _MentorHomeScreenState();
}

class _MentorHomeScreenState extends State<MentorHomeScreen> {
  // Ensure this service returns Future<bool> for recordSwipe as discussed previously
  final MenteeMatchingDataService _matchingService = MenteeMatchingDataService();
  
  final List<SwipeItem> _swipeItems = [];
  MatchEngine? _matchEngine;
  List<UserModel> _mentees = [];
  bool _isLoading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to see mentees.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final mentees = await _matchingService.getSuggestedMentees(user.uid);

      if (!mounted) return;

      setState(() {
        _mentees = mentees;
        _swipeItems.clear();
        
        for (var mentee in mentees) {
          _swipeItems.add(
            SwipeItem(
              content: mentee,
              // We pass the specific mentee and the swipe direction to the handler
              likeAction: () => _onSwipe(mentee, true),
              nopeAction: () => _onSwipe(mentee, false),
            ),
          );
        }

        if (_swipeItems.isNotEmpty) {
          _matchEngine = MatchEngine(swipeItems: _swipeItems);
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading mentees: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- UPDATED SWIPE HANDLER ---
  void _onSwipe(UserModel mentee, bool liked) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool isMatch = false;

    try {
      // 1. Await the service call to check for a match
      // This assumes recordSwipe returns Future<bool>
      isMatch = await _matchingService.recordSwipe(
        mentorId: user.uid, 
        menteeId: mentee.userId, 
        isLike: liked
      );
      print("UI: Service returned. isMatch = $isMatch");
    } catch (e) {
      print("Error recording swipe: $e");
      // Optionally show an error snackbar here
    }

    if (!mounted) return;

    // 2. If it is a match, show the Dialog!
    if (liked && isMatch) {
      // Create a temporary User Model for the current Mentor to display in the popup
      UserModel currentUserModel = UserModel(
        userId: user.uid,
        displayName: user.displayName ?? "You",
        bio: "Mentor", // 'bio' is required in your model
        profilePictureUrl: user.photoURL, 
        roles: ['mentor'], // 'roles' is required in your model
        isVerified: false,
      );
      showDialog(
        context: context,
        barrierDismissible: false, // User must click a button to exit
        builder: (context) {
          print("UI: Building MatchScreen Widget");
          return MatchScreen(
            currentUser: currentUserModel, 
            matchedUser: mentee,
          );
        },
      );
    } else {
      // 3. If no match (or skipped), show the standard SnackBar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(liked
              ? 'You liked ${mentee.displayName}'
              : 'You skipped ${mentee.displayName}'),
          duration: const Duration(milliseconds: 500),
          backgroundColor: liked ? AppTheme.chipGreen : Colors.grey,
        ),
      );
    }
  }

  // --- HELPER LOGIC FOR DATA EXTRACTION ---

  List<String> _getInterests(UserModel user) {
    return user.menteeProfile?.interests ?? [];
  }

  String _getBudgetDisplay(UserModel user) {
    final budgetMap = user.menteeProfile?.budget;
    if (budgetMap == null || budgetMap.isEmpty) {
      return 'Negotiable';
    }
    
    if (budgetMap.containsKey('min') && budgetMap.containsKey('max')) {
      final min = budgetMap['min']!.toInt();
      final max = budgetMap['max']!.toInt();
      return '\$$min - \$$max';
    }

    return budgetMap.values.map((e) => '\$${e.toInt()}').join(' - ');
  }

  // --- UI WIDGETS ---

  Widget _buildHeader(UserModel mentee) {
    final String? imageUrl = mentee.profilePictureUrl;
    final bool hasValidUrl = imageUrl != null && imageUrl.isNotEmpty;
    final bool isNetworkImage = hasValidUrl && imageUrl.startsWith('http');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          // 1. Profile Image
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
                            Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 50)),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ))
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
          ),

          // 2. Gradient Overlay
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

          // 3. Name and Interests (Bottom Left)
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
                        mentee.displayName.toUpperCase(),
                        style: AppTheme.montserratName.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (mentee.isVerified == true) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Colors.blueAccent, 
                        size: 24,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _getInterests(mentee).map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.chipGreen,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        interest,
                        style: AppTheme.montserratChip.copyWith(color: Colors.white),
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

  Widget _buildMenteeDetails(UserModel mentee) {
    final String duration = mentee.menteeProfile?.duration ?? 'Flexible';
    final String budgetString = _getBudgetDisplay(mentee);
    final List<String> goals = mentee.menteeProfile?.goals ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          _buildSectionTitle('About'),
          Text(mentee.bio, style: AppTheme.montserratBody),
          _buildDivider(),
          
          _buildSectionTitle("Preferred Duration"),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                duration, 
                style: AppTheme.montserratBody.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          _buildDivider(),

          _buildSectionTitle('My budget is:'),
          Text(
            budgetString,
            style: AppTheme.montserratBody.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          _buildDivider(),

          _buildSectionTitle('Goals:'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: goals.map((g) => _buildBodyChip(g)).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

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

  Widget _buildCard(UserModel mentee) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
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
            const Text('TURO', style: AppTheme.fustatHeader),
            Row(
              children: [
                Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 28),
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
                  : _mentees.isEmpty || _matchEngine == null
                      ? const Center(
                          child: Text(
                            'No more mentees available.\nCheck back later!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : SwipeCards(
                          matchEngine: _matchEngine!,
                          itemBuilder: (context, index) {
                            return _buildCard(_mentees[index]);
                          },
                          onStackFinished: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("That's all for now!"),
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
              onTap: (i) => setState(() => _navIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}