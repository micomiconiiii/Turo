import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Brand Colors
  static const Color primary = Color(0xFF104038);
  static const Color secondary = Color(0xFF3D3D3D);
  static const Color grey = Color(0xFFD9D9D9);
  static const Color lightGrey = Color(0xFFF4F4F4);
  static const Color alert = Color(0xFFFF3E3E);
  static const Color white = Color(0xFFFEFEFE);
  static const Color black = Color(0xFF3D3D3D);
  static const Color chipGreen = Color(0xFF2C6A64);

  // --- Fustat Styles ---

  // 1. Main Header ("TURO")
  static const TextStyle fustatHeader = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w800,
    fontSize: 32,
    color: black,
  );

  // 2. Body Chips (Goals, Looking For) -> Fustat 12
  // ADDED THIS SECTION
  static const TextStyle body3 = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: black,
  );

  // --- Montserrat Styles ---

  // 3. Name on Image
  static const TextStyle montserratName = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 32,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  // 4. Section Titles (About, Goals, etc.) -> SemiBold 20
  static const TextStyle montserratSectionTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20,
    color: black,
  );

  // 5. Details (Bio, Notes, Budget Value) -> Regular 15
  static const TextStyle montserratBody = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 15,
    color: secondary,
  );

  // 6. Header Chip Text (Image Overlay) -> Regular 12
  static const TextStyle montserratChip = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: white,
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Montserrat', // Set Default Font
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
        titleMedium: montserratSectionTitle,
        bodyLarge: montserratBody,
        bodyMedium: montserratBody,
        // You can map bodySmall to montserratChip or body3 depending on preference
        bodySmall: montserratChip,
      ),
    );
  }
}
