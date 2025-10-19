import 'package:flutter/material.dart';
import 'package:turo_profile_setup/screens/view/home_page_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 1. Keeps track of the currently selected tab
  int _selectedIndex = 0;

  // 2. The list of pages/views for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomePageView(), // Your new profile card view
    Center(child: Text('Calendar Page')), // Placeholder for 2nd tab
    Center(child: Text('Mentors Page')),   // Placeholder for 3rd tab
    Center(child: Text('Chat Page')),       // Placeholder for 4th tab
    Center(child: Text('Sessions Page')),  // Placeholder for 5th tab
  ];

  // 3. This function is called when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // The "TURO" title
        title: const Text(
          "TURO",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.black, // Set color to black
          ),
        ),
        // The icons on the right
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[800]),
            onPressed: () {
              // TODO: Handle notification tap
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.grey[800]),
            onPressed: () {
              // TODO: Handle profile tap (maybe go to a profile edit screen)
            },
          ),
          const SizedBox(width: 12), // A little padding
        ],
      ),
      
      // 4. The body of the scaffold shows the currently selected page
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // 5. The Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Filled icon when active
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Mentors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Sessions',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        
        // 6. Styling to match your brand
        backgroundColor: const Color(0xFF1B4D44), // Your dark green color
        selectedItemColor: Colors.white,       // Active icon color
        unselectedItemColor: Colors.white.withOpacity(0.6), // Inactive icon color
        type: BottomNavigationBarType.fixed, // Ensures all 5 tabs are shown
        showUnselectedLabels: false, // Hides labels for inactive tabs
        showSelectedLabels: false,   // Hides labels for active tabs
      ),
    );
  }
}