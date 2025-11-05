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

  TextStyle get headline32SemiBoldFustat => TextStyle(
        fontSize: 32.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Fustat',
        color: appTheme.black_900,
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

  TextStyle get title16RegularFustat => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Fustat',
        color: appTheme.gray_800,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body12RegularFustat => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Fustat',
        color: appTheme.color7F0000,
      );
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
  