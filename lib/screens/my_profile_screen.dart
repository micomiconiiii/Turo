import 'package:flutter/material.dart';
import 'profile_setup_screen.dart'; // To navigate to setup
import '../widgets/profile_widgets.dart'; // Import your new profile widgets

/// The main profile screen for the logged-in user.
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  /// Navigates to the profile setup flow.
  void _startProfileCompletion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupScreen(), // No flag needed anymore
      ),
    );
  }

  // Removed _buildChip, _buildSectionHeader, _buildExperienceItem methods
  // as they are now separate widgets in profile_widgets.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for contrast
      appBar: AppBar(
        // Keep AppBar styling as before
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('2'),
              child: Icon(Icons.notifications_outlined, color: Colors.grey[800]),
            ),
            onPressed: () { /* TODO: Notification tap */ },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.grey[800]),
            onPressed: () { /* TODO: Profile settings tap */ },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Profile Info Container ---
              // (This part is quite unique, so kept mostly inline)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [ BoxShadow( /* Shadow style */ ) ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar( /* Profile Picture */ ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MTRID124", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text("JOSEF GUBAN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  // Verify Icon triggers setup flow
                                  GestureDetector(
                                    onTap: () => _startProfileCompletion(context),
                                    child: const Icon(Icons.verified_outlined, color: Colors.blue, size: 20),
                                  ),
                                  const Spacer(),
                                  // Edit Icon also triggers setup flow for now
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
                              Text(
                                "I am interested in giving consultations on User Research and Front-end Technology", // <-- FIXED: Added the actual text
                                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              Text("Birthday: 12/12/2000", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row( // Rating and Role Row
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [ /* Star Icons */ const SizedBox(width: 8), Text("4.5/5"), /* Divider */ Text("Expert Mentor") ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Availability Section ---
              // Use the reusable ProfileSectionCard
              ProfileSectionCard(
                title: "Availability",
                onAdd: () { /* TODO: Handle Add Availability */ },
                // Content for the Availability section
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: const [ // Use the reusable InfoChip
                        InfoChip(label: "Monday"),
                        InfoChip(label: "Tuesday"),
                        InfoChip(label: "Thursday"),
                        InfoChip(label: "Friday"),
                        InfoChip(label: "Sunday"),
                      ],
                    ),
                     Align( // Align UTC text to the right
                      alignment: Alignment.centerRight,
                      child: Text("UTC+8", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Skills Section ---
              // Use ProfileSectionCard again, adding the blue border
              ProfileSectionCard(
                title: "Skills",
                onAdd: () { /* TODO: Handle Add Skills */ },
                hasBorder: true, // Add the blue border
                // Content for the Skills section
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: const [ // Use InfoChip with isFilled: true
                    InfoChip(label: "UI/UX", isFilled: true),
                    InfoChip(label: "Frontend", isFilled: true),
                    InfoChip(label: "Backend", isFilled: true),
                    InfoChip(label: "Project Management", isFilled: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Experience Section ---
              // Header outside the card for this design
              const Text(
                "Experience",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Use a Container for the card background/styling, content uses ExperienceItem
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // No bottom padding inside
                 decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                   boxShadow: [ BoxShadow( /* Shadow style */ ) ],
                ),
                // Content for Experience section
                child: Column(
                  children: const [ // Use the reusable ExperienceItem widget
                    ExperienceItem(title: "Senior Developer", company: "Microsoft", dates: "2015 - 2019"),
                    ExperienceItem(title: "Junior Developer", company: "Microsoft", dates: "2013 - 2015"),
                    ExperienceItem(title: "UI/UX Designer", company: "Freelance", dates: "2012 - 2013",
                     // Remove bottom padding for the last item if needed, handled by container padding
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}