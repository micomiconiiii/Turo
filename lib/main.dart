import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turo/presentation/auth_wrapper.dart';
import 'firebase_options.dart';
import 'core/app_export.dart';
import 'package:turo/theme/mentor_app_theme.dart'; // Import theme

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase from the first version
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set preferred orientations from both versions
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Use the more robust DevicePreview setup from the second version
  runApp(
    DevicePreview(
      enabled: !const bool.fromEnvironment('dart.vm.product'),
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the Sizer that is now in its own file
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Turo', // Using the more descriptive title
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData, // Using the theme from the second version
          locale: DevicePreview.locale(context),
          // Using the builder from the second version to handle text scaling
          builder: (context, child) {
            return DevicePreview.appBuilder(
              context,
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
          // Adding localizations from the second version
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
        );
      },
    );
  }
}
