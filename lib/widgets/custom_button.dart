import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// A customizable button widget that supports various styling options
///
/// Features:
/// - Customizable text, colors, and dimensions
/// - Full-width layout support
/// - Disabled state handling
/// - Responsive design with SizeUtils
/// - Material Design interactions
///
/// Arguments:
/// - [text]: The text to display on the button
/// - [onPressed]: Callback function when button is tapped
/// - [backgroundColor]: Background color of the button
/// - [textColor]: Color of the button text
/// - [borderRadius]: Corner radius of the button
/// - [height]: Height of the button
/// - [width]: Width of the button (use double.infinity for full width)
/// - [isDisabled]: Whether the button is disabled
/// - [margin]: External margin around the button
/// - [padding]: Internal padding of the button
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.height,
    this.width,
    this.isDisabled,
    this.margin,
    this.padding,
  });

  final String? text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final double? height;
  final double? width;
  final bool? isDisabled;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 14.h, vertical: 14.h),
      child: SizedBox(
        height: height ?? 48.h,
        width: width ?? double.infinity,
        child: ElevatedButton(
          onPressed: (isDisabled ?? false) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Color(0xFF10403B),
            disabledBackgroundColor:
                (backgroundColor ?? Color(0xFF10403B)).withAlpha(128),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 14.h),
            ),
            padding: padding ??
                EdgeInsets.symmetric(vertical: 8.h, horizontal: 30.h),
            elevation: 0,
          ),
          child: Text(
            text ?? "Next",
            style: TextStyleHelper.instance.title20SemiBoldFustat
                .copyWith(color: textColor ?? Color(0xFFFEFEFE), height: 1.45),
          ),
        ),
      ),
    );
  }
}
  