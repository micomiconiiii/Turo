// Core Flutter material design package for widgets, themes, navigation, etc.
import 'package:flutter/material.dart';
// Provides kReleaseMode flag to enable/disable features based on build mode.
import 'package:flutter/foundation.dart';
// DevicePreview helps preview layouts on multiple devices/sizes during dev.
import 'package:device_preview/device_preview.dart';
// Centralized route definitions for the app.
import 'package:turo_app/routes/app_routes.dart';
// Provider package for dependency injection and state management.
import 'package:provider/provider.dart';
// Global onboarding state storage (ChangeNotifier) used across steps.
import 'package:turo_app/mentee-onboarding/provider_storage/storage.dart';

// Application entry point. Sets up DevicePreview and global Provider, then runs app.
void main() {
  // runApp mounts the widget tree and starts the Flutter app.
  runApp(
    // Wrap the app with DevicePreview to emulate devices when not in release.
    DevicePreview(
      enabled: !kReleaseMode, // Disable in release builds for performance.
      // builder provides the child for DevicePreview; we inject our Provider and App.
      builder: (context) => ChangeNotifierProvider(
        // Create a single MenteeOnboardingProvider instance for the entire app.
        create: (_) => MenteeOnboardingProvider(),
        // MyApp contains MaterialApp and top-level configuration.
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // MaterialApp configures navigation, theming, localization, etc.
    return MaterialApp(
      // Title used by the OS/task switcher and some widgets.
      title: 'Flutter Demo',
      // Define the app theme; ColorScheme seeded from a base color.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // First screen to show when app launches.
      initialRoute: AppRoutes.initialRoute,
      // Map of route names to widget builders.
      routes: AppRoutes.routes,
      // Integrate DevicePreview locale for testing different locales.
      locale: DevicePreview.locale(context),
      // Wrap app UI with DevicePreview’s appBuilder for frame/scale overlays.
      builder: DevicePreview.appBuilder,
    );
  }
}
