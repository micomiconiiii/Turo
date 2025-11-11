import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_export.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/mentee_onboarding/providers/mentee_onboarding_provider.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nyneapamoopinciztmgd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55bmVhcGFtb29waW5jaXp0bWdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDY1ODMsImV4cCI6MjA3NjIyMjU4M30.UY8hmGf9BJPw10t75vP2B2_3UMZmzvf_NlO5Rylu6-E',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
    );
    
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    DevicePreview(
      enabled: true, // turn off in production
      builder: (context) => MyApp(),
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
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            initialRoute: AppRoutes.initialRoute,
            routes: AppRoutes.routes,
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
