import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_image_view.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool rememberMe = false;

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF10403B),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 86.h),
              _buildLogoSection(context),
              SizedBox(height: 42.h),
              _buildLoginFormSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 113.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            child: CustomImageView(
              imagePath: ImageConstant.imgVectorWhiteA700,
              height: 206.h,
              width: 164.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(right: 24.h),
            child: Text(
              'TURO',
              style: TextStyleHelper.instance.display40ExtraBoldFustat
                  .copyWith(height: 1.43, color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 36.h, vertical: 24.h),
      decoration: BoxDecoration(
        color: Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(20.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'Log in',
              style: TextStyleHelper.instance.display32SemiBoldFustat
                  .copyWith(height: 1.44, color: Color(0xFF3D3D3D)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'Please Sign in to continue',
              style: TextStyleHelper.instance.body16RegularFustat
                  .copyWith(height: 1.44, color: Color(0xFF3D3D3D)),
            ),
          ),
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: CustomEditText(
              controller: usernameController,
              placeholder: 'Username',
              prefixIconPath: ImageConstant.imgVectorGray800,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: CustomEditText(
              controller: passwordController,
              placeholder: 'Password',
              prefixIconPath: ImageConstant.imgVectorGray80018x20,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 8.h),
          _buildRememberMeSection(context),
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: CustomButton(
              text: 'Log in',
              width: double.infinity,
              onPressed: () => _onLoginPressed(context),
            ),
          ),
          SizedBox(height: 8.h),
          _buildSignUpSection(context),
          SizedBox(height: 102.h),
        ],
      ),
    );
  }

  Widget _buildRememberMeSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Remember me',
            style: TextStyleHelper.instance.body16SemiBoldFustat
                .copyWith(height: 1.44, color: Color(0xFF2C6A64)),
          ),
          Container(
            width: 20.h,
            height: 20.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF10403B),
                width: 1.h,
              ),
              borderRadius: BorderRadius.circular(5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 24.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account yet? ",
                style: TextStyleHelper.instance.body16RegularFustat
                    .copyWith(height: 1.44, color: Color(0xFF3D3D3D)),
              ),
              TextSpan(
                text: "Sign up",
                style: TextStyleHelper.instance.body16SemiBoldFustat
                    .copyWith(height: 1.38, color: Color(0xFF2C6A64)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Clear form fields after successful validation
      usernameController.clear();
      passwordController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Color(0xFF10403B),
        ),
      );

      // Navigate to splash screen (as it's the only other screen available)
      Navigator.of(context).pushReplacementNamed(AppRoutes.splashScreen);
    }
  }
}
