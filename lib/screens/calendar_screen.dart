import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// 1. Import the details screen
import 'event_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // --- STATE VARIABLES ---
  bool _isCalendarExpanded = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _selectedMenteeIndex = 0;

  // --- COLOR CONSTANTS ---
  final Color _primaryGreen = const Color(0xFF10403B);   // For Tags
  final Color _secondaryGreen = const Color(0xFF2C6A64); // For Card Backgrounds

  // Dummy Mentees Data
  final List<Map<String, String>> _mentees = [
    {'name': 'Anna', 'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
    {'name': 'Charles', 'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
    {'name': 'Melanie', 'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
    {'name': 'Troy', 'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
    {'name': 'Kevin', 'image': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
  ];

  // Helper to generate 7 days starting from the Sunday of the currently focused week
  List<DateTime> _getDaysForWeek(DateTime focusedDay) {
    final currentWeekday = focusedDay.weekday;
    final daysToSubtract = currentWeekday == 7 ? 0 : currentWeekday; 
    final firstDayOfWeek = focusedDay.subtract(Duration(days: daysToSubtract));
    
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  void _toggleCalendar() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, _focusedDay.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysForWeek(_focusedDay);
    final monthName = DateFormat('MMMM').format(_focusedDay); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // --- APP BAR TITLE ---
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.grey),
              onPressed: _previousMonth,
            ),
            GestureDetector(
              onTap: _toggleCalendar,
              child: Text(
                monthName,
                style: const TextStyle(
                    color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.grey),
              onPressed: _nextMonth,
            ),
          ],
        ),
        centerTitle: true,
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
          const SizedBox(width: 8),
        ],
      ),
      
      body: Stack(
        children: [
          // --- LAYER A: The Main Content ---
          Column(
            children: [
              // Week View
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((day) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDay = day;
                            _focusedDay = day;
                          });
                        },
                        child: _buildDayItem(day),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 20),

              _buildMenteeSelector(),

              const SizedBox(height: 10),
              const Divider(thickness: 1, height: 1),

              // Timeline View
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // 7:00 AM
                      _buildTimeRow(
                        "7:00",
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildEventCard(
                                status: "Completed",
                                timeRange: "7:00 - 7:30",
                                name: "Anna Maralit",
                                tag: "Quiz",
                                color: _secondaryGreen, 
                                tagColor: _primaryGreen, 
                                textColor: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              _buildEventCard(
                                status: "Cancelled",
                                timeRange: "7:00 - 7:30",
                                name: "Anna Maralit",
                                tag: "Meeting",
                                color: Colors.grey[300]!,
                                tagColor: _primaryGreen, // Primary green tag even on grey card
                                textColor: Colors.grey[700]!,
                                isCancelled: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 7:30 AM
                      _buildTimeRow(
                        "7:30",
                        _buildEventCard(
                          status: "Upcoming",
                          timeRange: "7:30 - 8:30",
                          name: "Anna Maralit",
                          tag: "Meeting",
                          color: Colors.grey[300]!,
                          tagColor: _primaryGreen, 
                          textColor: Colors.grey[700]!,
                          height: 140,
                          icon: Icons.refresh,
                        ),
                      ),
                      _buildTimeRow("8:00", const SizedBox(height: 60)),
                      _buildTimeRow("8:30", const SizedBox(height: 60)),
                      _buildTimeRow("9:00", const SizedBox(height: 60)),
                      
                       // 9:30 AM
                       _buildTimeRow(
                        "9:30",
                        _buildEventCard(
                          status: "Completed",
                          timeRange: "9:30 - 10:30",
                          name: "Anna Maralit",
                          tag: "Review",
                          color: _secondaryGreen, 
                          tagColor: _primaryGreen, 
                          textColor: Colors.white,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- LAYER B: The Calendar Dropdown Overlay ---
          if (_isCalendarExpanded)
            Positioned(
              top: 0, 
              left: 0, 
              right: 0,
              child: GestureDetector(
                onTap: _toggleCalendar,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                      padding: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                _isCalendarExpanded = false; 
                              });
                            },
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                            },
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              leftChevronVisible: true,
                              rightChevronVisible: true,
                            ),
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: _secondaryGreen, 
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: const BoxDecoration(
                                 shape: BoxShape.circle,
                                 color: Colors.transparent,
                              ),
                              todayTextStyle: TextStyle(color: _secondaryGreen, fontWeight: FontWeight.bold),
                              defaultTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildDayItem(DateTime day) {
    final isSelected = isSameDay(day, _selectedDay);
    final dayName = DateFormat('E').format(day); 
    final dayNumber = DateFormat('d').format(day); 

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? _secondaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              color: isSelected ? Colors.white70 : Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayNumber,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF333333),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenteeSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _mentees.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedMenteeIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedMenteeIndex = index),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: _secondaryGreen, width: 2)
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(_mentees[index]['image']!),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _mentees[index]['name']!,
                    style: TextStyle(
                      color: isSelected ? _secondaryGreen : Colors.grey, 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeRow(String time, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String status,
    required String timeRange,
    required String name,
    required String tag,
    required Color color, 
    required Color textColor,
    required Color tagColor, 
    double height = 110,
    bool isCancelled = false,
    IconData? icon,
  }) {
    return Container(
      width: 160,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCancelled ? Icons.close : (icon ?? Icons.check),
                color: isCancelled ? Colors.red : textColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            timeRange,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
          const Spacer(),
          Text(
            name,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor, 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              
              // --- UPDATED: CLICKABLE ELLIPSIS ---
              GestureDetector(
                onTap: () {
                  // Navigate to the Event Details Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(
                        status: status,
                        menteeName: name,
                      ),
                    ),
                  );
                },
                child: Icon(Icons.more_horiz, color: textColor, size: 20),
              ),
            ],
          )
        ],
      ),
    );
  }
}