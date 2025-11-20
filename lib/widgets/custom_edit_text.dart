import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

class CustomEditText extends StatefulWidget {
  CustomEditText({
    Key? key,
    this.controller,
    this.placeholder,
    this.prefixIconPath,
    this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.onTap,
    this.width,
    this.margin,
    this.labelText,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? placeholder;
  final String? prefixIconPath;
  final IconData? prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final double? width;
  final EdgeInsets? margin;
  final String? labelText;

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
    return Container(
      width: widget.width,
      margin: widget.margin,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isObscureText : false,
        validator: widget.validator,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        onTap: widget.onTap,
        style: TextStyleHelper.instance.body16RegularFustat.copyWith(
          color: Color(0xFF3D3D3D),
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(color: Colors.black.withAlpha(128)),
          hintText: widget.placeholder ?? "",
          hintStyle: TextStyle(color: Colors.black.withAlpha(64)),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: Colors.black.withAlpha(128),
                  size: 20.h,
                )
              : (widget.prefixIconPath != null
                    ? Padding(
                        padding: EdgeInsets.all(12.h),
                        child: CustomImageView(
                          imagePath: widget.prefixIconPath!,
                          height: 18.h,
                          width: widget.prefixIconPath!.contains('18x20')
                              ? 20.h
                              : 16.h,
                          fit: BoxFit.contain,
                        ),
                      )
                    : null),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withAlpha(64)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withAlpha(64)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withAlpha(64), width: 2),
          ),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.h),
            borderSide: BorderSide(color: Colors.red, width: 1.h),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.h),
            borderSide: BorderSide(color: Colors.red, width: 1.h),
          ),
        ),
      ),
    );
  }
}
