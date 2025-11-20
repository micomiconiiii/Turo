import 'package:flutter/foundation.dart' show kReleaseMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_export.dart';
import 'presentation/mentee_onboarding/providers/mentee_onboarding_provider.dart';
import 'presentation/admin/admin_auth_wrapper.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Mode selection: default is admin, set USER_MODE=true for user flow
const bool _userMode = bool.fromEnvironment('USER_MODE', defaultValue: false);

// Unified entry-point: chooses admin (web) or user (mobile) surfaces automatically.
// - Web + USER_MODE=false (default): Admin panel
// - Web + USER_MODE=true: User flow with DevicePreview (for Edge)
// - Mobile/Desktop native: User flow
//
// Run commands:
//   Admin (Chrome):  flutter run -d chrome
//   User (Edge):     flutter run -d edge --dart-define=USER_MODE=true --web-port=8080
//   Mobile:          flutter run -d <device-id>

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Determine if we should show DevicePreview:
  // - Always enable for native mobile in debug mode
  // - Enable for web when user mode is active (to preview mobile layouts in browser)
  final bool enableDevicePreview = !kReleaseMode && (!kIsWeb || _userMode);

  runApp(
    DevicePreview(
      enabled: enableDevicePreview,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine which entry point to show:
    // - If on web AND not in user mode → show admin panel
    // - Otherwise → show user app (LoginScreen)
    final bool showAdmin = kIsWeb && !_userMode;

    return ChangeNotifierProvider(
      create: (_) => MenteeOnboardingProvider(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'turo_mentor',
            debugShowCheckedModeBanner: false,
            locale: showAdmin ? null : DevicePreview.locale(context),
            builder: showAdmin ? null : DevicePreview.appBuilder,
            // Platform-driven entry selection:
            // Admin web: provide home only (no '/' in routes)
            // User mode: omit home and use initialRoute + routes (routes contains '/')
            home: showAdmin ? const AdminAuthWrapper() : null,
            initialRoute: showAdmin ? null : AppRoutes.initialRoute,
            routes: showAdmin
                ? const <String, WidgetBuilder>{}
                : AppRoutes.routes,
            scrollBehavior: MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
          );
        },
      ),
    );
  }
}
