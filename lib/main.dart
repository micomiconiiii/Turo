import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_export.dart';
import 'presentation/mentee_onboarding/providers/mentee_onboarding_provider.dart';
import 'presentation/admin/pages/admin_login_page.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Testing Flag: Set to true to test Admin Panel features in isolation
///
/// When true:
/// - DevicePreview is disabled (app fills the browser window)
/// - Entry point is AdminLoginPage (bypasses normal app flow)
/// - Ideal for web/desktop admin panel development
///
/// When false:
/// - Normal app flow with mobile DevicePreview
/// - Standard entry point (SplashScreen/AuthWrapper)
const bool testAdmin = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    DevicePreview(
      // Only enable DevicePreview for mobile testing (not in production or admin testing)
      // Admin Panel is web/desktop, so it should fill the browser without device frame
      enabled: !kReleaseMode && !testAdmin,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenteeOnboardingProvider(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'turo_mentor',
            debugShowCheckedModeBanner: false,
            locale: testAdmin ? null : DevicePreview.locale(context),
            builder: testAdmin ? null : DevicePreview.appBuilder,
            // Switch entry point based on testing mode
            home: testAdmin ? const AdminLoginPage() : null,
            initialRoute: testAdmin ? null : AppRoutes.initialRoute,
            // If home is specified, we must not also register a '/' route.
            // Avoid the Flutter assertion by omitting routes when testing admin.
            routes: testAdmin
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
