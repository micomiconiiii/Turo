import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_image_view.dart';

class MentorRegistrationScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  MentorRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF10403B),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 84.h),
            _buildLogoSection(context),
            SizedBox(height: 26.h),
            _buildRegistrationForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Column(
      children: [
        CustomImageView(
          imagePath: ImageConstant.imgGroup222WhiteA700,
          height: 206.h,
          width: 164.h,
        ),
        Text(
          'TURO',
          style: TextStyleHelper.instance.display40ExtraBoldFustat
              .copyWith(color: Color(0xFFECEEF0)),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 0.h),
      decoration: BoxDecoration(
        color: Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(20.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(36.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.only(left: 4.h),
                child: Text(
                  'Register',
                  style: TextStyleHelper.instance.display32SemiBoldFustat
                      .copyWith(color: Color(0xFF3D3D3D)),
                ),
              ),
              SizedBox(height: 24.h),
              _buildTabSection(context),
              SizedBox(height: 22.h),
              _buildFormFields(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.h),
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: TabBar(
          indicatorColor: Color(0xFF2C6A64),
          labelColor: Color(0xFF3D3D3D),
          unselectedLabelColor: Color(0xFF3D3D3D),
          labelStyle: TextStyleHelper.instance.body16RegularFustat,
          tabs: [
            Tab(text: "I'm a Mentee"),
            Tab(text: "I'm a Mentor"),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.h),
      child: Column(
        children: [
          CustomEditText(
            controller: usernameController,
            placeholder: 'Username',
            prefixIconPath: ImageConstant.imgVectorGray800,
            validator: _validateUsername,
          ),
          SizedBox(height: 16.h),
          CustomEditText(
            controller: emailController,
            placeholder: 'Email',
            prefixIconPath: ImageConstant.imgEmail1572,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          SizedBox(height: 16.h),
          CustomEditText(
            controller: passwordController,
            placeholder: 'Password',
            prefixIconPath: ImageConstant.imgVectorGray80018x20,
            isPassword: true,
            validator: _validatePassword,
          ),
          SizedBox(height: 16.h),
          CustomEditText(
            controller: confirmPasswordController,
            placeholder: 'Confirm Password',
            prefixIconPath: ImageConstant.imgVectorGray80018x20,
            isPassword: true,
            validator: _validateConfirmPassword,
          ),
          SizedBox(height: 22.h),
          CustomButton(
            text: 'Sign Up',
            onPressed: () => _onSignUpPressed(context),
            width: double.infinity,
          ),
          SizedBox(height: 6.h),
          _buildSignInText(context),
        ],
      ),
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return GestureDetector(
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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter valid email';
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
      return 'Please confirm password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _onSignUpPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Clear form fields after successful validation
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Color(0xFF10403B),
        ),
      );

      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.loginScreen);
    }
  }

  void _onSignInPressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.loginScreen);
  }
}
