import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_image_view.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  void _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email != null) {
      setState(() {
        emailController.text = email;
        rememberMe = true;
      });
    } else {
      setState(() {
        rememberMe = false;
      });
    }
  }

  void _handleRememberMe(bool? value) {
    setState(() {
      rememberMe = value ?? false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF10403B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: EdgeInsets.only(left: 16.h, top: 16.h),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28.h,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildLogoSection(context),
                SizedBox(height: 42.h),
                _buildLoginFormSection(context),
              ],
            ),
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
              style: TextStyleHelper.instance.display40ExtraBoldFustat.copyWith(
                height: 1.43,
                color: Color(0xFFFFFFFF),
              ),
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
              style: TextStyleHelper.instance.display32SemiBoldFustat.copyWith(
                height: 1.44,
                color: Color(0xFF3D3D3D),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'Please Sign in to continue',
              style: TextStyleHelper.instance.body16RegularFustat.copyWith(
                height: 1.44,
                color: Color(0xFF3D3D3D),
              ),
            ),
          ),
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: CustomEditText(
              controller: emailController,
              placeholder: 'Email',
              prefixIconPath: ImageConstant.imgVectorGray800,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Please enter a valid email address';
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
            style: TextStyleHelper.instance.body16SemiBoldFustat.copyWith(
              height: 1.44,
              color: Color(0xFF2C6A64),
            ),
          ),
          Checkbox(
            value: rememberMe,
            onChanged: _handleRememberMe,
            activeColor: Color(0xFF10403B),
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
        child: GestureDetector(
          onTap: () {
            if (AppRoutes.routes.containsKey(AppRoutes.mentorHomeScreen)) {
              Navigator.of(context)
                  .pushNamed(AppRoutes.mentorHomeScreen);
            } else {
              // Handle the case where the route is not defined
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registration screen not available.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Don't have an account yet? ",
                  style: TextStyleHelper.instance.body16RegularFustat.copyWith(
                    height: 1.44,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
                TextSpan(
                  text: "Sign up",
                  style:
                      TextStyleHelper.instance.body16SemiBoldFustat.copyWith(
                    height: 1.38,
                    color: Color(0xFF2C6A64),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginPressed(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('email', emailController.text);
      } else {
        await prefs.remove('email');
      }

      try {
        final user = await _authService.signInWithEmailPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (user != null) {
          // --- ROLE-BASED REDIRECTION ---
          // 1. Get user data from Firestore
          final dbService = DatabaseService(); // Assuming you have this service
          final userDoc = await dbService.getUser(user.uid);

          if (!userDoc.exists) {
            throw Exception('User data not found in database.');
          }

          // 2. Check roles
          final data = userDoc.data() as Map<String, dynamic>;
          final roles = List<String>.from(data['roles'] ?? []);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful! Welcome back.'),
              backgroundColor: Color(0xFF10403B),
            ),
          );

          // 3. Navigate based on role
          if (roles.contains('mentor')) {
            Navigator.of(context)
                .pushReplacementNamed(AppRoutes.mentorHomeScreen);
          } else {
            Navigator.of(context)
                .pushReplacementNamed(AppRoutes.appNavigationScreen);
          }
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
