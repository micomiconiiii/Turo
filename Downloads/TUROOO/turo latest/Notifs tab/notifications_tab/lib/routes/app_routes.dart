import 'package:flutter/material.dart';
import '../presentation/notifications_all_screen/notifications_all_screen.dart';
import '../presentation/notifications_unread_screen/notifications_unread_screen.dart';
import '../presentation/notifications_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String notificationsAllScreen = '/notifications_all_screen';
  static const String notificationsUnreadScreen =
      '/notifications_unread_screen';
  static const String notificationsScreen = '/notifications_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
        notificationsAllScreen: (context) => NotificationsAllScreen(),
        notificationsUnreadScreen: (context) => NotificationsUnreadScreen(),
        notificationsScreen: (context) => NotificationsScreen(),
        appNavigationScreen: (context) => AppNavigationScreen(),
        initialRoute: (context) => NotificationsScreen()
      };
}
