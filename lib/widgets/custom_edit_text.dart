import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomEditText - A reusable text input field widget with customizable styling and functionality
 * 
 * Features:
 * - Prefix icon support with SVG images
 * - Password field with visibility toggle
 * - Form validation support
 * - Responsive design with SizeUtils
 * - Customizable styling and keyboard types
 * 
 * @param controller - TextEditingController for managing text input
 * @param placeholder - Hint text displayed when field is empty
 * @param prefixIconPath - Path to SVG icon displayed at the start of field
 * @param isPassword - Whether this field should hide text input (password field)
 * @param validator - Validation function for form validation
 * @param keyboardType - Type of keyboard to display for input
 * @param onTap - Callback function when field is tapped (useful for date pickers)
 */
class CustomEditText extends StatefulWidget {
  CustomEditText({
    Key? key,
    this.controller,
    this.placeholder,
    this.prefixIconPath,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.onTap,
  }) : super(key: key);

  /// Controller for managing the text input
  final TextEditingController? controller;

  /// Placeholder text shown when field is empty
  final String? placeholder;

  /// Path to the prefix icon SVG image
  final String? prefixIconPath;

  /// Whether this field should hide text input (password field)
  final bool isPassword;

  /// Validation function for form validation
  final String? Function(String?)? validator;

  /// Type of keyboard to display
  final TextInputType? keyboardType;

  /// Callback function when field is tapped
  final VoidCallback? onTap;

  @override
  State<CustomEditText> createState() => _CustomEditTextState();
}

class _CustomEditTextState extends State<CustomEditText> {
  bool _isObscureText = true;

  @override
  void initState() {
    super.initState();
    _isObscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscureText : false,
      validator: widget.validator,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      onTap: widget.onTap,
      style: TextStyleHelper.instance.body16RegularFustat
          .copyWith(color: Color(0xFF3D3D3D)),
      decoration: InputDecoration(
        hintText: widget.placeholder ?? "",
        hintStyle: TextStyleHelper.instance.body16RegularFustat
            .copyWith(color: Color(0xFF3D3D3D)),
        filled: true,
        fillColor: Color(0xFFD9D9D9),
        prefixIcon: widget.prefixIconPath != null
            ? Padding(
                padding: EdgeInsets.all(12.h),
                child: CustomImageView(
                  imagePath: widget.prefixIconPath!,
                  height: 18.h,
                  width: widget.prefixIconPath!.contains('18x20') ? 20.h : 16.h,
                  fit: BoxFit.contain,
                ),
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscureText ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF3D3D3D),
                  size: 20.h,
                ),
                onPressed: () {
                  setState(() {
                    _isObscureText = !_isObscureText;
                  });
                },
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          vertical: 4.h,
          horizontal: 12.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.h),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.h),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.h),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.h),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.h,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.h),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.h,
          ),
        ),
      ),
    );
  }
}
