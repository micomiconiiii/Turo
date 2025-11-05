import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // --- 1. IMPORT AUTH & FIRESTORE ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_setup_screen.dart'; 
import '../widgets/profile_widgets.dart'; // Your reusable profile widgets

/// The main profile screen for the logged-in user.
// --- 2. CONVERT TO STATEFULWIDGET ---
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  
  // --- 3. DEFINE A STREAM TO LISTEN TO THE USER'S DOCUMENT ---
  late final Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    
    // Get the current user's ID
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    
    if (uid != null) {
      // Point the stream to the user's document in Firestore
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(); // .snapshots() provides the real-time stream
    } else {
      // Handle the rare case where the user is null
      _userStream = Stream.empty();
    }
  }

  /// Navigates to the profile setup flow.
  void _startProfileCompletion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupScreen(),
      ),
    );
  }

  // (Your _buildChip, _buildSectionHeader, _buildExperienceItem helpers
  // are now correctly in profile_widgets.dart)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        // (Your AppBar code is unchanged)
        backgroundColor: Colors.white,
        elevation: 1, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("My Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('2'),
              child: Icon(Icons.notifications_outlined, color: Colors.grey[800]),
            ),
            onPressed: () { /* TODO: Handle notification tap */ },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.grey[800]),
            onPressed: () {
              // --- CHANGED ---
              // Example: Add a temporary log out button for testing
              FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      
      // --- 4. USE A STREAMBUILDER TO LISTEN FOR DATA ---
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream, // Listen to the user's document
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          
          // --- 5. HANDLE LOADING STATE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 6. HANDLE ERROR STATE ---
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          // --- 7. HANDLE NO DATA STATE ---
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User document not found."));
          }

          // --- 8. HANDLE SUCCESS STATE ---
          // We have the data! Extract it.
          // Note: .data() can be null, so check for existence first.
          final data = snapshot.data!.data() as Map<String, dynamic>?;

          // Get data from the document, providing default values
          final picUrl = data?['profilePictureUrl']; // Will be null if not set
          final expertiseList = List<String>.from(data?['expertise'] ?? []); // Default to empty list
          
          // (You can get your other data here too)
          // final rates = data?['rates'] as Map<String, dynamic>? ?? {'min': 'N/A', 'max': 'N/A'};
          // final aboutMe = data?['aboutMe'] ?? "No 'About Me' set.";
          
          // --- This is your existing UI, now using live data ---
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Top Profile Card ---
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- 9. UPDATE PROFILE PICTURE ---
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.grey[200], // Background for if image is null
                              // Use the URL from Firestore. If it's null, use the placeholder
                              backgroundImage: (picUrl != null)
                                ? NetworkImage(picUrl) // Load image from Firebase Storage
                                : const NetworkImage( // Placeholder
                                    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXZhdGFyfGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60')
                                    as ImageProvider, // Cast to satisfy type
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // (User ID, Name, etc. are hardcoded, you can fetch these too)
                                  Text("MTRID124", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text("JOSEF GUBAN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _startProfileCompletion(context),
                                        child: const Icon(Icons.verified_outlined, color: Colors.blue, size: 20),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                         onTap: () => _startProfileCompletion(context),
                                        child: Icon(Icons.edit_outlined, color: Colors.grey[600], size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text("Software Developer", style: TextStyle(fontSize: 14, color: Colors.black54)),
                                  const SizedBox(height: 12),
                                  const Text("About me", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  // TODO: Add 'aboutMe' to your setup flow and display it here
                                  Text(
                                    "I am interested in giving consultations on User Research and Front-end Technology",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Birthday: 12/12/2000",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // (Rating and Role - still hardcoded)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const Icon(Icons.star_half, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text("4.5/5", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                            const SizedBox(width: 16),
                            Container(height: 15, width: 1, color: Colors.grey[300]),
                             const SizedBox(width: 16),
                             Text("Expert Mentor", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Availability Section (still hardcoded) ---
                  ProfileSectionCard(
                    title: "Availability",
                    onAdd: () { /* TODO: Handle Add Availability */ },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          children: const [
                            InfoChip(label: "Monday"),
                            InfoChip(label: "Tuesday"),
                            InfoChip(label: "Thursday"),
                          ],
                        ),
                         Align(
                          alignment: Alignment.centerRight,
                          child: Text("UTC+8", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Skills Section ---
                  ProfileSectionCard(
                    title: "Skills",
                    onAdd: () { /* TODO: Handle Add Skills */ },
                    hasBorder: true,
                    // --- 10. UPDATE SKILLS ---
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      // Create an InfoChip for each item in the 'expertiseList' from Firestore
                      children: expertiseList.map((skill) => InfoChip(
                        label: skill,
                        isFilled: true,
                      )).toList(), // Convert the mapped items to a List<Widget>
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Experience Section (still hardcoded) ---
                  const Text("Experience", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                     decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                       boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        ExperienceItem(title: "Senior Developer", company: "Microsoft", dates: "2015 - 2019"),
                        ExperienceItem(title: "Junior Developer", company: "Microsoft", dates: "2013 - 2015"),
                        ExperienceItem(title: "UI/UX Designer", company: "Freelance", dates: "2012 - 2013"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}