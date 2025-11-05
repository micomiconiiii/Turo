import 'package:flutter/material.dart';

/// TURO App Theme — follows your brand book
class AppTheme {
  // 🎨 Brand Colors
  static const Color primary = Color(0xFF104038); // Main brand color
  static const Color secondary = Color(0xFF3D3D3D); // Dark text/neutral
  static const Color grey = Color(0xFFD9D9D9); // Neutral
  static const Color lightGrey = Color(0xFFF4F4F4); // Background
  static const Color alert = Color(0xFFFF3E3E); // Red alert
  static const Color white = Color(0xFFFEFEFE);
  static const Color black = Color(0xFF3D3D3D);

  // 🟢 TURO’s accent chip color (used in tags & budget)
  static const Color chipGreen = Color(0xFF2C6A64);

  // ✍️ Text Styles (Fustat default)
  static const TextStyle fustatHeader = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w800,
    fontSize: 32,
    color: black,
  );

  static const TextStyle fustatSubHeader = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: black,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: black,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: black,
  );

  static const TextStyle body3 = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: black,
  );

  // --- Montserrat styles for specific requirements ---
  static const TextStyle montserratName = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 32,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  static const TextStyle montserratSectionTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20,
    color: primary,
  );

  // 🌈 App ThemeData (for MaterialApp)
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Fustat',
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: white,
        secondary: secondary,
        onSecondary: white,
        error: alert,
        onError: white,
        surface: white,
        onSurface: black,
      ),
      textTheme: const TextTheme(
        headlineLarge: fustatHeader,
        titleMedium: fustatSubHeader,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: body3,
      ),
    );
  }
}
