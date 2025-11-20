import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/notification_item_widget.dart';

class NotificationsUnreadScreen extends StatelessWidget {
  NotificationsUnreadScreen({Key? key}) : super(key: key);

  // Sample data for notifications
  final List<Map<String, dynamic>> recentNotifications = [
    {
      "profileImage": ImageConstant.imgEllipse32,
      "message": "Mico Abas sent you a new message",
      "timestamp": "1hr",
    },
    {
      "profileImage": ImageConstant.imgEllipse3240x40,
      "message": "Jhondel Nofies transferred you PHP3,000",
      "timestamp": "1hr",
    },
    {
      "profileImage": ImageConstant.imgEllipse321,
      "message": "Nico Chan sent you a new message",
      "timestamp": "1hr",
    },
  ];

  final List<Map<String, dynamic>> last7DaysNotifications = [
    {
      "profileImage": ImageConstant.imgEllipse322,
      "message": "Jose Santos sent you a new message",
      "timestamp": "1wk",
    },
  ];

  final List<Map<String, dynamic>> last2WeeksNotifications = [
    {
      "profileImage": ImageConstant.imgEllipse324,
      "message": "Rich Cua sent you a new message",
      "timestamp": "2wks",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteCustom,
      appBar: CustomAppBar(
        leadingIconPath: ImageConstant.imgVector,
        backgroundColor: appTheme.whiteCustom,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              SizedBox(height: 12.h),
              _buildNotificationsContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyleHelper.instance.headline24SemiBoldFustat,
        ),
        SizedBox(height: 16.h),
        _buildFilterButtons(context),
      ],
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _onAllButtonPressed(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 8.h),
            decoration: BoxDecoration(
              color: appTheme.colorFFE0E0,
              borderRadius: BorderRadius.circular(20.h),
            ),
            child: Text(
              'All',
              style: TextStyleHelper.instance.body14MediumFustat,
            ),
          ),
        ),
        SizedBox(width: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 8.h),
          decoration: BoxDecoration(
            color: appTheme.colorFF2E7D,
            borderRadius: BorderRadius.circular(20.h),
          ),
          child: Text(
            'Unread',
            style: TextStyleHelper.instance.body14MediumFustat
                .copyWith(color: appTheme.whiteCustom),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecentSection(context),
        SizedBox(height: 24.h),
        _buildLast7DaysSection(context),
        SizedBox(height: 24.h),
        _buildLast2WeeksSection(context),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent',
          style: TextStyleHelper.instance.title20SemiBoldFustat,
        ),
        SizedBox(height: 4.h),
        Container(
          margin: EdgeInsets.only(left: 2.h),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentNotifications.length,
            itemBuilder: (context, index) {
              return NotificationItemWidget(
                profileImage: recentNotifications[index]['profileImage'],
                message: recentNotifications[index]['message'],
                timestamp: recentNotifications[index]['timestamp'],
                onTap: () => _onNotificationTap(context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLast7DaysSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 days',
          style: TextStyleHelper.instance.title20SemiBoldFustat,
        ),
        SizedBox(height: 10.h),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: last7DaysNotifications.length,
          itemBuilder: (context, index) {
            return NotificationItemWidget(
              profileImage: last7DaysNotifications[index]['profileImage'],
              message: last7DaysNotifications[index]['message'],
              timestamp: last7DaysNotifications[index]['timestamp'],
              onTap: () => _onNotificationTap(context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLast2WeeksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 2 weeks ago',
          style: TextStyleHelper.instance.title20SemiBoldFustat,
        ),
        SizedBox(height: 14.h),
        NotificationItemWidget(
          profileImage: last2WeeksNotifications[0]['profileImage'],
          message: last2WeeksNotifications[0]['message'],
          timestamp: last2WeeksNotifications[0]['timestamp'],
          onTap: () => _onNotificationTap(context),
        ),
      ],
    );
  }

  void _onAllButtonPressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.notificationsAllScreen);
  }

  void _onNotificationTap(BuildContext context) {
    // Handle notification tap - could navigate to detailed view
    print('Notification tapped');
  }
}
