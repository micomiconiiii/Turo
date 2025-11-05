<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TuroApp());
}

class TuroApp extends StatelessWidget {
  const TuroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Fustat', // ✅ Use Fustat font globally
        scaffoldBackgroundColor: const Color(0xFF1A3A3A),
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
          bodyMedium:
              TextStyle(color: Colors.white70, fontWeight: FontWeight.w400),
          titleLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontFamily: 'Fustat',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_export.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'mentee_sign_up',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
        );
      },
    );
  }
}
>>>>>>> 63aa055 (Initial commit)
