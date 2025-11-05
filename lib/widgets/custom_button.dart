import 'package:flutter/material.dart';

import '../core/app_export.dart';

/**
 * CustomButton - A reusable button component with customizable styling
 * 
 * @param text - Button text content
 * @param onPressed - Callback function when button is pressed
 * @param backgroundColor - Background color of the button
 * @param textColor - Color of the button text
 * @param fontSize - Font size of the button text
 * @param fontWeight - Font weight of the button text
 * @param borderRadius - Border radius of the button
 * @param padding - Internal padding of the button
 * @param margin - External margin of the button
 * @param height - Height of the button
 * @param width - Width of the button
 * @param isExpanded - Whether button should take full width
 */
class CustomButton extends StatelessWidget {
  CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.isExpanded,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final bool? isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(top: 40.h, left: 4.h),
      height: height ?? 48.h,
      width: isExpanded == true ? double.infinity : width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF10403B),
          padding: padding ??
              EdgeInsets.symmetric(
                vertical: 8.h,
                horizontal: 30.h,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 14.h),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyleHelper.instance.title20SemiBoldFustat.copyWith(
              fontSize: fontSize ?? 20.fSize,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: textColor ?? Color(0xFFFEFEFE),
              height: 1.45),
        ),
      ),
    );
  }
}
