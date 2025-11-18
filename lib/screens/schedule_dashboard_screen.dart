import 'package:flutter/material.dart';
import 'calendar_screen.dart'; 
import 'mentor_booking_screen.dart'; 

class ScheduleDashboardScreen extends StatelessWidget {
  const ScheduleDashboardScreen({super.key});

  // --- COLORS ---
  final Color _primaryGreen = const Color(0xFF1B4D44);
  final Color _secondaryGreen = const Color(0xFF2C6A64);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Schedule",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            letterSpacing: 0.5,
          ),
        ),
        actions: [
           Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- SECTION 1: BOOKING CALENDAR PREVIEW ---
            const Text(
              "Booking Calendar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 12),
            _buildPreviewContainer(
              height: 220,
              content: _buildDummyTimeline(),
              button: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("View Calendar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 32),

            // --- SECTION 2: CURRENT SCHEDULE PREVIEW ---
            const Text(
              "Current Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 12),
            _buildPreviewContainer(
              height: 260,
              content: _buildDummyScheduleList(),
              button: ElevatedButton(
                onPressed: () {
                   // --- CHANGED NAVIGATION ---
                   Navigator.push(
                    context,
                    // Navigates to the screen with Profile, Tabs, and Bottom Sheet
                    MaterialPageRoute(builder: (context) => const MentorBookingScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Add a Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPERS (Same as before) ---
  Widget _buildPreviewContainer({required double height, required Widget content, required Widget button}) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias, 
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: content,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.9), 
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: button,
          ),
        ],
      ),
    );
  }

  Widget _buildDummyTimeline() {
    return Column(
      children: [
        _buildTimeRow("7:00", 
          Row(children: [
             _buildMiniCard("Completed", _secondaryGreen, "Quiz"),
             const SizedBox(width: 8),
             _buildMiniCard("Cancelled", Colors.grey[300]!, "Meeting", textColor: Colors.black),
          ])
        ),
        const SizedBox(height: 16),
        _buildTimeRow("7:30", _buildMiniCard("Upcoming", Colors.grey[300]!, "Review", textColor: Colors.black, height: 60)),
      ],
    );
  }

  Widget _buildTimeRow(String time, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 12),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildMiniCard(String status, Color color, String tag, {Color textColor = Colors.white, double height = 50}) {
    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check, size: 10, color: textColor),
                const SizedBox(width: 4),
                Text(status, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
               decoration: BoxDecoration(color: const Color(0xFF10403B), borderRadius: BorderRadius.circular(4)),
               child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 8)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDummyScheduleList() {
    return Column(
      children: [
        _buildScheduleItem("Sunday, September 21"),
        _buildScheduleItem("Monday, September 22"),
        _buildScheduleItem("Tuesday, September 23"),
        _buildScheduleItem("Wednesday, September 24"),
      ],
    );
  }

  Widget _buildScheduleItem(String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              const Text("7:00 am - 7:30 am", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Icon(Icons.check_box_outline_blank, color: Colors.black),
        ],
      ),
    );
  }
}