import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomAppBar - A reusable AppBar component with customizable leading icon
 * 
 * Features:
 * - Implements PreferredSizeWidget for proper AppBar integration
 * - Supports custom leading icon with SVG/PNG/Network images
 * - Configurable background color and height
 * - Optional onPressed callback for navigation handling
 * - Responsive design using SizeUtils extensions
 * 
 * @param leadingIconPath - Path to the leading icon (SVG, PNG, or network URL)
 * @param backgroundColor - Background color of the AppBar
 * @param height - Custom height for the AppBar
 * @param onLeadingPressed - Callback function when leading icon is pressed
 * @param leadingWidth - Width of the leading icon
 * @param leadingHeight - Height of the leading icon
 */
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    Key? key,
    this.leadingIconPath,
    this.backgroundColor,
    this.height,
    this.onLeadingPressed,
    this.leadingWidth,
    this.leadingHeight,
  }) : super(key: key);

  /// Path to the leading icon image
  final String? leadingIconPath;

  /// Background color of the AppBar
  final Color? backgroundColor;

  /// Custom height for the AppBar
  final double? height;

  /// Callback function when leading icon is pressed
  final VoidCallback? onLeadingPressed;

  /// Width of the leading icon
  final double? leadingWidth;

  /// Height of the leading icon
  final double? leadingHeight;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? appTheme.transparentCustom,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: leadingIconPath != null ? _buildLeadingIcon() : null,
      leadingWidth: leadingWidth ?? 56.h,
      toolbarHeight: height ?? 56.h,
    );
  }

  /// Builds the leading icon widget
  Widget _buildLeadingIcon() {
    return GestureDetector(
      onTap: onLeadingPressed,
      child: Container(
        padding: EdgeInsets.all(18.h),
        child: CustomImageView(
          imagePath: leadingIconPath ?? ImageConstant.imgVector,
          height: leadingHeight ?? 18.h,
          width: leadingWidth ?? 10.h,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.h);
}
