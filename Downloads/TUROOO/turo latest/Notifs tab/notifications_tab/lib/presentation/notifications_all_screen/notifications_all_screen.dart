import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/notification_item_widget.dart';

class NotificationsAllScreen extends StatelessWidget {
  NotificationsAllScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700_01,
      appBar: CustomAppBar(
        leadingIconPath: ImageConstant.imgVector,
        onLeadingPressed: () => Navigator.pop(context),
        height: 56.h,
        leadingWidth: 56.h,
        leadingHeight: 18.h,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildTabBar(context),
              _buildNotificationsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Text(
        'Notifications',
        style: TextStyleHelper.instance.headline32ExtraBoldFustat
            .copyWith(height: 1.44),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 26.h,
        left: 62.h,
        right: 62.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      decoration: BoxDecoration(
        color: appTheme.blue_gray_100,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Handle All tab selection
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.h,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: appTheme.colorFF2E7D,
                  borderRadius: BorderRadius.circular(14.h),
                ),
                child: Center(
                  child: Text(
                    'All',
                    style: TextStyleHelper.instance.title16BoldFustat
                        .copyWith(height: 1.44),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                    context, AppRoutes.notificationsUnreadScreen);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.h,
                  vertical: 8.h,
                ),
                child: Center(
                  child: Text(
                    'Unread',
                    style: TextStyleHelper.instance.title16RegularFustat
                        .copyWith(height: 1.44),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 12.h,
        right: 4.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentSection(context),
          SizedBox(height: 12.h),
          _buildLast7DaysSection(context),
          SizedBox(height: 12.h),
          _buildLast2WeeksSection(context),
          SizedBox(height: 12.h),
          _buildAdditionalNotification(context),
        ],
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    List<Map<String, String>> recentNotifications = [
      {
        'imagePath': ImageConstant.imgEllipse32,
        'message': 'Mico Abas sent you a new message',
        'timestamp': '1hr',
      },
      {
        'imagePath': ImageConstant.imgEllipse3240x40,
        'message': 'Jhondel Nofies transferred you PHP3,000',
        'timestamp': '1hr',
      },
      {
        'imagePath': ImageConstant.imgEllipse321,
        'message': 'Nico Chan sent you a new message',
        'timestamp': '1hr',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent',
          style: TextStyleHelper.instance.title20SemiBoldFustat
              .copyWith(height: 1.45),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.only(left: 2.h),
          child: Column(
            children: recentNotifications
                .map((notification) => NotificationItemWidget(
                      imagePath: notification['imagePath']!,
                      message: notification['message']!,
                      timestamp: notification['timestamp']!,
                      onTap: () {
                        // Handle notification tap
                      },
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLast7DaysSection(BuildContext context) {
    List<Map<String, String>> last7DaysNotifications = [
      {
        'imagePath': ImageConstant.imgEllipse322,
        'message': 'Jose Santos sent you a new message',
        'timestamp': '1wk',
      },
      {
        'imagePath': ImageConstant.imgEllipse323,
        'message': 'A new session was created for Hannah Dy',
        'timestamp': '1wk',
      },
      {
        'imagePath': ImageConstant.imgEllipse321,
        'message': 'Gio Sy just gave you a feedback. Check it out',
        'timestamp': '1wk',
      },
      {
        'imagePath': ImageConstant.imgEllipse321,
        'message': 'Gio Sy just gave you a feedback. Check it out',
        'timestamp': '1wk',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 days',
          style: TextStyleHelper.instance.title20SemiBoldFustat
              .copyWith(height: 1.45),
        ),
        SizedBox(height: 10.h),
        Column(
          children: last7DaysNotifications
              .map((notification) => NotificationItemWidget(
                    imagePath: notification['imagePath']!,
                    message: notification['message']!,
                    timestamp: notification['timestamp']!,
                    onTap: () {
                      // Handle notification tap
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLast2WeeksSection(BuildContext context) {
    List<Map<String, String>> last2WeeksNotifications = [
      {
        'imagePath': ImageConstant.imgEllipse324,
        'message': 'Rich Cua sent you a new message',
        'timestamp': '2wks',
      },
      {
        'imagePath': ImageConstant.imgEllipse323,
        'message': 'You have a new match! Check it out',
        'timestamp': '2wks',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 2 weeks ago',
          style: TextStyleHelper.instance.title20SemiBoldFustat
              .copyWith(height: 1.45),
        ),
        SizedBox(height: 10.h),
        Column(
          children: last2WeeksNotifications
              .map((notification) => NotificationItemWidget(
                    imagePath: notification['imagePath']!,
                    message: notification['message']!,
                    timestamp: notification['timestamp']!,
                    onTap: () {
                      // Handle notification tap
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalNotification(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: NotificationItemWidget(
        imagePath: ImageConstant.imgEllipse321,
        message: 'Gio Sy just gave you a feedback. Check it out',
        timestamp: '2wks',
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
}
