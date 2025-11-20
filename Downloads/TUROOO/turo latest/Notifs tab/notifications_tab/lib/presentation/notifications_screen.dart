import 'package:flutter/material.dart';
import '../core/app_export.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _currentView = 'All';

  // Sample data
  final List<Map<String, dynamic>> _notifications = [
    {
      'senderName': 'Mico Abas',
      'message': 'sent you a new message',
      'timeAgo': '1hr',
      'isRead': false,
      'avatarPath': 'assets/images/MicoAbas.png',
    },
    {
      'senderName': 'Jhondel Nofies',
      'message': 'transferred you PHP3,000',
      'timeAgo': '1hr',
      'isRead': true,
      'avatarPath': 'assets/images/JhondelNofies.png',
    },
    {
      'senderName': 'Gio Sy',
      'message': 'just gave you a feedback. Check it out',
      'timeAgo': '1wk',
      'isRead': true,
      'avatarPath': 'assets/images/GioSy.png',
    },
    {
      'senderName': '',
      'message': 'A new session was created for Hannah Dy',
      'timeAgo': '1wk',
      'isRead': true,
      'avatarPath': 'assets/images/HannahDy.png',
    },
    {
      'senderName': 'You have a new match!',
      'message': 'Check it out',
      'timeAgo': '2wks',
      'isRead': true,
      'avatarPath': 'assets/images/HannahDy.png',
    },
    {
      'senderName': 'Nico Chan',
      'message': 'sent you a new message',
      'timeAgo': '1hr',
      'isRead': false,
      'avatarPath': 'assets/images/NicoChan.png',
    },
    {
      'senderName': 'Jose Santos',
      'message': 'sent you a new message',
      'timeAgo': '1wk',
      'isRead': false,
      'avatarPath': 'assets/images/JoseSantos.png',
    },
    {
      'senderName': 'Rich Cua',
      'message': 'sent you a new message',
      'timeAgo': '2wks',
      'isRead': false,
      'avatarPath': 'assets/images/RichCua.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_currentView == 'All') {
      return _notifications;
    } else {
      return _notifications.where((item) => !item['isRead']).toList();
    }
  }

  Map<String, List<Map<String, dynamic>>> get _groupedNotifications {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var item in _filteredNotifications) {
      final group = _getGroup(item['timeAgo']);
      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(item);
    }
    return grouped;
  }

  String _getGroup(String timeAgo) {
    switch (timeAgo) {
      case '1hr':
        return 'Recent';
      case '1wk':
        return 'Last 7 days';
      case '2wks':
        return 'Last 2 weeks ago';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.w800,
            fontFamily: 'Fustat',
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            // Segmented Control
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 6.h,
              decoration: BoxDecoration(
                color: Color(0xFFD3D3D3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentView = 'All'),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _currentView == 'All'
                              ? Color(0xFF10403B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'All',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: _currentView == 'All'
                                ? Colors.white
                                : Color(0xFF10403B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentView = 'Unread'),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _currentView == 'Unread'
                              ? Color(0xFF10403B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Unread',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: _currentView == 'Unread'
                                ? Colors.white
                                : Color(0xFF10403B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            ..._groupedNotifications.entries.map((entry) {
              final group = entry.key;
              final items = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      group,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Fustat',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ...items.map((item) => Column(
                        children: [
                          ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: AssetImage(
                                      item['avatarPath'] ??
                                          ImageConstant.imgEllipse32),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: item['isRead']
                                          ? Colors.grey.shade400
                                          : Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${item['senderName']} ',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: item['isRead']
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Fustat',
                                    ),
                                  ),
                                  TextSpan(
                                    text: item['message'],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: item['isRead']
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Fustat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Text(
                              item['timeAgo'],
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                                fontFamily: 'Fustat',
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Divider(color: Colors.grey.shade300),
                        ],
                      )),
                  SizedBox(height: 3.h),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
