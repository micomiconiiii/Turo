import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_image_view.dart';

class UserRegistrationScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  UserRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF10403B),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 84.h),
            // Logo section
            SizedBox(
              width: 164.h,
              height: 206.h,
              child: CustomImageView(
                imagePath: ImageConstant.imgGroup222WhiteA700,
                height: 206.h,
                width: 164.h,
              ),
            ),
            SizedBox(height: 1.h),
            // TURO text
            Text(
              'TURO',
              style: TextStyleHelper.instance.display40ExtraBoldFustat
                  .copyWith(color: Color(0xFFECEEF0)),
            ),
            SizedBox(height: 26.h),
            // Registration form container
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 0.h),
              decoration: BoxDecoration(
                color: Color(0xFFFEFEFE),
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Register title
                  Padding(
                    padding: EdgeInsets.only(top: 24.h, left: 40.h),
                    child: Text(
                      'Register',
                      style: TextStyleHelper.instance.display32SemiBoldFustat
                          .copyWith(color: Color(0xFF3D3D3D)),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  // Tab bar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 38.h),
                    padding: EdgeInsets.symmetric(horizontal: 26.h),
                    child: _buildTabBar(context),
                  ),
                  SizedBox(height: 27.h),
                  // Form section
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 36.h, vertical: 22.h),
                    child: _buildRegistrationForm(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF3D3D3D),
                  width: 2.h,
                ),
              ),
            ),
            child: Text(
              "I'm a Mentee",
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body16RegularFustat
                  .copyWith(color: Color(0xFF3D3D3D)),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              "I'm a Mentor",
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body16RegularFustat
                  .copyWith(color: Color(0xFF3D3D3D)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Username field
          CustomEditText(
            controller: _usernameController,
            placeholder: 'Username',
            prefixIconPath: ImageConstant.imgVectorGray800,
            validator: _validateUsername,
          ),
          SizedBox(height: 16.h),
          // Email field
          CustomEditText(
            controller: _emailController,
            placeholder: 'Email',
            prefixIconPath: ImageConstant.imgEmail1572,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          SizedBox(height: 16.h),
          // Password field
          CustomEditText(
            controller: _passwordController,
            placeholder: 'Password',
            prefixIconPath: ImageConstant.imgVectorGray80018x20,
            isPassword: true,
            validator: _validatePassword,
          ),
          SizedBox(height: 16.h),
          // Confirm Password field
          CustomEditText(
            controller: _confirmPasswordController,
            placeholder: 'Confirm Password',
            prefixIconPath: ImageConstant.imgVectorGray80018x20,
            isPassword: true,
            validator: _validateConfirmPassword,
          ),
          SizedBox(height: 22.h),
          // Sign Up button
          CustomButton(
            text: 'Sign Up',
            onPressed: () => _onSignUpPressed(context),
            backgroundColor: Color(0xFF10403B),
            textColor: Color(0xFFFEFEFE),
            fontSize: 20.fSize,
            fontWeight: FontWeight.w600,
            borderRadius: 14.h,
            height: 48.h,
            isExpanded: true,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 30.h),
          ),
          SizedBox(height: 6.h),
          // Sign in link
          GestureDetector(
            onTap: () => _onSignInPressed(context),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyleHelper.instance.body16RegularFustat
                        .copyWith(color: Color(0xFF3D3D3D)),
                  ),
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyleHelper.instance.body16SemiBoldFustat
                        .copyWith(color: Color(0xFF2C6A64)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _onSignUpPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Color(0xFF10403B),
        ),
      );

      // Clear form fields
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Navigate to login screen after successful registration
      Navigator.of(context).pushReplacementNamed(AppRoutes.loginScreen);
    }
  }

  void _onSignInPressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.loginScreen);
  }
}
