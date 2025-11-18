import 'package:flutter/material.dart';
import 'schedule_dashboard_screen.dart'; // Import your new dashboard

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // This list holds the screen for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home Page Placeholder')), // Tab 0: Home
    ScheduleDashboardScreen(),                    // Tab 1: Schedule (The feature you built!)
    Center(child: Text('Mentors Page Placeholder')), // Tab 2: Mentors
    Center(child: Text('Chat Page Placeholder')),    // Tab 3: Chat
    Center(child: Text('Sessions Page Placeholder')),// Tab 4: Sessions
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body switches based on the selected index
      body: _widgetOptions.elementAt(_selectedIndex),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
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
        
        // Styling
        backgroundColor: const Color(0xFF1B4D44), 
        selectedItemColor: const Color(0xFF1B4D44), // Active color
        unselectedItemColor: Colors.grey, // Inactive color
        type: BottomNavigationBarType.fixed, // Keeps all 5 icons visible
        showUnselectedLabels: false,
        showSelectedLabels: false,
      ),
    );
  }
}