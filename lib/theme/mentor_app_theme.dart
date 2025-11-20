// For details on the theme of Mentor Home Page
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF104038);
  static const Color secondary = Color(0xFF3D3D3D);
  static const Color grey = Color(0xFFD9D9D9);
  static const Color lightGrey = Color(0xFFF4F4F4);
  static const Color alert = Color(0xFFFF3E3E);
  static const Color white = Color(0xFFFEFEFE);
  static const Color black = Color(0xFF3D3D3D);
  static const Color chipGreen = Color(0xFF2C6A64);

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

  static const TextStyle body3 = TextStyle(
    fontFamily: 'Fustat',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: black,
  );

  static const TextStyle montserratName = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 32,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  static const TextStyle montserratSectionTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: black,
  );

  static const TextStyle montserratBody = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: secondary,
  );

  static const TextStyle montserratChip = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: white,
  );

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
        titleMedium: montserratSectionTitle,
        bodyLarge: body1,
        bodyMedium: montserratBody,
        bodySmall: body3,
      ),
    );
  }
}
