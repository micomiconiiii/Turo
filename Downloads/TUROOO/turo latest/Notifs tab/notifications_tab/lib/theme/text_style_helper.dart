import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline32ExtraBoldFustat => TextStyle(
        fontSize: 32.fSize,
        fontWeight: FontWeight.w800,
        fontFamily: 'Fustat',
        color: appTheme.black_900,
      );

  TextStyle get headline24SemiBoldFustat => TextStyle(
        fontSize: 24.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Fustat',
        color: appTheme.black_900_01,
      );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  TextStyle get title20SemiBoldFustat => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Fustat',
        color: appTheme.black_900_01,
      );

  TextStyle get title16BoldFustat => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Fustat',
        color: appTheme.white_A700,
      );

  TextStyle get title16RegularFustat => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Fustat',
        color: appTheme.gray_800,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14MediumFustat => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Fustat',
        color: appTheme.colorFF6666,
      );

  TextStyle get body12RegularFustat => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Fustat',
        color: appTheme.color7F3D3D,
      );
}
