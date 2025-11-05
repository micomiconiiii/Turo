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

  // Display Styles
  // Large text styles for prominent headings

  TextStyle get display40ExtraBoldFustat => TextStyle(
        fontSize: 40.fSize,
        fontWeight: FontWeight.w800,
        fontFamily: 'Fustat',
      );

  TextStyle get display32SemiBoldFustat => TextStyle(
        fontSize: 32.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Fustat',
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
      );

  // Body Styles
  // Regular text styles for body content

  TextStyle get body16RegularFustat => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Fustat',
      );

  TextStyle get body16SemiBoldFustat => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Fustat',
      );

  // Label Styles
  // Small text styles for labels and captions

  TextStyle get label10RegularFustat => TextStyle(
        fontSize: 10.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Fustat',
      );

  TextStyle get label12RegularFustat => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Fustat',
      );
}
