import 'package:flutter/material.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  // Helper widget to build the tag chips on the profile card
  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      margin: const EdgeInsets.only(right: 8, top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25), // Translucent white
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper widget to build the "Looking for" chips
  Widget _buildLookingForChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D44), // Your brand color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Allows the content to scroll if it's too tall for the screen
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. The Profile Card
            Card(
              clipBehavior: Clip.antiAlias, // Ensures the image corners are rounded
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 5,
              child: Stack(
                children: [
                  // --- The Background Image ---
                  // TODO: Replace with user's actual image URL from Firebase
                  Image.network(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80',
                    height: 450,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  
                  // --- The Gradient Overlay (for text readability) ---
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.4],
                        ),
                      ),
                    ),
                  ),
                  
                  // --- The Text and Tags ---
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20, // Ensure Wrap doesn't overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: Replace with data from Firestore
                        const Text(
                          "MICO ABAS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          children: [
                            _buildTagChip("UI/UX"),
                            _buildTagChip("Frontend"),
                            _buildTagChip("Backend"),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. "About" Section
            // TODO: Replace with data from Firestore
            const Text(
              "About",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "I am a student taking up Bachelor of Science in Information Technology",
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
            ),
            const Divider(height: 40),

            // 3. "I'm looking for" Section
            // TODO: Replace with data from Firestore
            const Text(
              "I'm looking for:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              children: [
                _buildLookingForChip("Software Engineer"),
                _buildLookingForChip("IT Mentor"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}