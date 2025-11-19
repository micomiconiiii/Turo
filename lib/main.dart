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
import 'presentation/admin/admin_main_view.dart';
import 'presentation/login_screen/login_screen.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Unified entry-point: chooses admin (web) or user (mobile) surfaces automatically.
// - Web (kIsWeb): loads Admin panel shell directly.
// - Mobile/Desktop native: loads normal app flow via routes starting at AppRoutes.initialRoute.
// No manual flags required; run `flutter run -d chrome` for admin, `flutter run -d android` for user.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    DevicePreview(
      // Enable DevicePreview only for non-web debug (helps mobile layout testing)
      enabled: !kReleaseMode && !kIsWeb,
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
            locale: kIsWeb ? null : DevicePreview.locale(context),
            builder: kIsWeb ? null : DevicePreview.appBuilder,
            // Platform-driven entry selection
            home: kIsWeb ? AdminMainView() : LoginScreen(),
            // For mobile we rely on named routes after LoginScreen
            routes: kIsWeb ? const <String, WidgetBuilder>{} : AppRoutes.routes,
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
