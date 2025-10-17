import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// CustomEditText - Reusable text input field with dynamic text color on focus/typing
class CustomEditText extends StatefulWidget {
  const CustomEditText({
    Key? key,
    this.placeholder,
    this.validator,
    this.keyboardType,
    this.width,
    this.margin,
    this.controller,
    this.onChanged,
    this.enabled,
  }) : super(key: key);

  final String? placeholder;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool? enabled;

  @override
  State<CustomEditText> createState() => _CustomEditTextState();
}

class _CustomEditTextState extends State<CustomEditText> {
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      margin: widget.margin,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        enabled: widget.enabled ?? true,
        onChanged: widget.onChanged,
        style: TextStyleHelper.instance.title16RegularFustat.copyWith(
          color: Colors.black,
          height: 23.h / 16.fSize,
        ),
        decoration: InputDecoration(
          labelText: widget.placeholder ?? "",
          labelStyle: TextStyleHelper.instance.title16RegularFustat.copyWith(
            color: Colors.black.withOpacity(0.5),
            height: 23.h / 16.fSize,
          ),
          floatingLabelStyle: TextStyleHelper.instance.title16RegularFustat.copyWith(
            color: Colors.black,
            fontSize: 13.fSize,
            height: 1.2,
          ),
          contentPadding: EdgeInsets.all(10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.h),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.h),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.h),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.25), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.h),
            borderSide: BorderSide(color: Colors.red.withOpacity(0.8)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.h),
            borderSide: BorderSide(color: Colors.red.withOpacity(0.8), width: 2),
          ),
        ),
      ),
    );
  }
}
