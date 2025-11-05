import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/city_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'institutional_verification_screen.dart';

class MentorRegistrationScreen extends StatefulWidget {
  const MentorRegistrationScreen({super.key});

  @override
  State<MentorRegistrationScreen> createState() =>
      _MentorRegistrationScreenState();
}

class _MentorRegistrationScreenState extends State<MentorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressUnitBldgController =
      TextEditingController();
  final TextEditingController _addressStreetController = TextEditingController();
  final TextEditingController _addressBarangayController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h, left: 20.h, right: 20.h),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: 'Next',
                  onPressed: () => _onNextPressed(context),
                ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- HEADER ----
                Text(
                  'TURO',
                  style: TextStyleHelper.instance.headline32SemiBoldFustat
                      .copyWith(height: 1.44),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mentor Registration',
                      style: TextStyleHelper.instance.title20SemiBoldFustat
                          .copyWith(color: appTheme.gray_800, height: 1.45),
                    ),
                    Text(
                      'Step 1 out of 6',
                      style: TextStyleHelper.instance.body12RegularFustat
                          .copyWith(height: 1.5),
                    ),
                  ],
                ),

                // ---- PROGRESS BAR ----
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProgressSegment(filled: true),
                      SizedBox(width: 2.h),
                      _buildProgressSegment(filled: false),
                      SizedBox(width: 2.h),
                      _buildProgressSegment(filled: false),
                      SizedBox(width: 2.h),
                      _buildProgressSegment(filled: false),
                      SizedBox(width: 2.h),
                      _buildProgressSegment(filled: false),
                      SizedBox(width: 2.h),
                      _buildProgressSegment(filled: false),
                    ],
                  ),
                ),

                // ---- PROFILE ICON ----
                SizedBox(height: 24.h),
                Center(
                  child: Container(
                    height: 100.h,
                    width: 100.h,
                    decoration: BoxDecoration(
                      color: appTheme.blue_gray_700,
                      borderRadius: BorderRadius.circular(50.h),
                    ),
                    child: Center(
                      child: CustomImageView(
                        imagePath: ImageConstant.imgPath184,
                        height: 50.h,
                        width: 50.h,
                      ),
                    ),
                  ),
                ),

                // ---- TITLE ----
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    'Register',
                    style: TextStyleHelper.instance.title20SemiBoldFustat
                        .copyWith(color: appTheme.gray_800, height: 1.45),
                  ),
                ),
                Center(
                  child: Text(
                    'Join Turo as a mentor and start sharing your expertise',
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(color: appTheme.gray_800, height: 1.5),
                  ),
                ),

                // ---- FORM ----
                SizedBox(height: 20.h),
                _buildLabeledField(
                  label: 'Full Name',
                  placeholder: 'Full Name',
                  controller: _fullNameController,
                  validator: _validateFullName,
                  keyboardType: TextInputType.name,
                ),
                _buildBirthdateFields(context),
                _buildLabeledField(
                  label: 'Bio',
                  placeholder: 'Describe yourself',
                  controller: _bioController,
                  validator: _validateBio,
                  keyboardType: TextInputType.multiline,
                ),
                _buildLabeledField(
                  label: 'Unit, Building, etc.',
                  placeholder: 'Unit, Building, etc.',
                  controller: _addressUnitBldgController,
                  validator: _validateAddress,
                  keyboardType: TextInputType.streetAddress,
                ),
                _buildLabeledField(
                  label: 'Street',
                  placeholder: 'Street',
                  controller: _addressStreetController,
                  validator: _validateAddress,
                  keyboardType: TextInputType.streetAddress,
                ),
                _buildLabeledField(
                  label: 'Barangay',
                  placeholder: 'Barangay',
                  controller: _addressBarangayController,
                  validator: _validateAddress,
                  keyboardType: TextInputType.streetAddress,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CityField(
                        controller: _cityController,
                        label: 'City',
                        hintText: 'Start typing your city...',
                      ),
                    ],
                  ),
                ),
                _buildLabeledField(
                  label: 'Province',
                  placeholder: 'Province',
                  controller: _provinceController,
                  validator: _validateAddress,
                  keyboardType: TextInputType.streetAddress,
                ),
                _buildLabeledField(
                  label: 'Zip Code',
                  placeholder: 'Zip Code',
                  controller: _zipCodeController,
                  validator: _validateZipCode,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSegment({required bool filled}) {
    return Container(
      height: 6.h,
      width: 52.h,
      decoration: BoxDecoration(
        color: filled ? appTheme.blue_gray_700 : appTheme.blue_gray_100,
        borderRadius: BorderRadius.circular(3.h),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      child: CustomEditText(
        placeholder: placeholder,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        margin: EdgeInsets.only(right: 4.h),
      ),
    );
  }

  Widget _buildBirthdateFields(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      child: Row(
        children: [
          CustomEditText(
            placeholder: 'Month',
            controller: _monthController,
            validator: _validateMonth,
            keyboardType: TextInputType.number,
            width: MediaQuery.of(context).size.width * 0.24,
          ),
          SizedBox(width: 10.h),
          CustomEditText(
            placeholder: 'Day',
            controller: _dayController,
            validator: _validateDay,
            keyboardType: TextInputType.number,
            width: MediaQuery.of(context).size.width * 0.24,
          ),
          SizedBox(width: 10.h),
          Expanded(
            child: CustomEditText(
              placeholder: 'Year',
              controller: _yearController,
              validator: _validateYear,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateFullName(String? value) {
    if (value?.isEmpty == true) return 'Full name is required';
    return null;
  }

  String? _validateMonth(String? value) {
    if (value?.isEmpty == true) return 'Month is required';
    final month = int.tryParse(value!);
    if (month == null || month < 1 || month > 12) {
      return 'Enter valid month (1-12)';
    }
    return null;
  }

  String? _validateDay(String? value) {
    if (value?.isEmpty == true) return 'Day is required';
    final day = int.tryParse(value!);
    if (day == null || day < 1 || day > 31) return 'Enter valid day (1-31)';
    return null;
  }

  String? _validateYear(String? value) {
    if (value?.isEmpty == true) return 'Year is required';
    final year = int.tryParse(value!);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear) {
      return 'Enter valid year';
    }
    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Zip Code is required';
    }

    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value)) {
      return 'Zip Code must contain numbers only';
    }

    return null;
  }

  String? _validateBio(String? value) {
    if (value?.isEmpty == true) return 'Bio is required';
    if (value!.length < 10) return 'Bio must be at least 10 characters';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value?.isEmpty == true) return 'This field is required';
    return null;
  }

  void _onNextPressed(BuildContext context) {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoading = true;
      });
      _saveProfileData(context);
    }
  }

  Future<void> _saveProfileData(BuildContext context) async {
    try {
      // The user must be logged in to get a UID and call the function.
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception("You must be logged in to register.");
      }

      final int month = int.parse(_monthController.text);
      final int day = int.parse(_dayController.text);
      final int year = int.parse(_yearController.text);
      final DateTime birthdate = DateTime(year, month, day);

      // This is the data payload we will send to our Cloud Function.
      final Map<String, dynamic> userProfileData = {
        'fullName': _fullNameController.text,
        'birthdate': birthdate.toIso8601String(), // Send as a string
        'bio': _bioController.text,
        'address': {
          'unitBldg': _addressUnitBldgController.text,
          'street': _addressStreetController.text,
          'barangay': _addressBarangayController.text,
          'city': _cityController.text,
          'province': _provinceController.text,
          'zipCode': _zipCodeController.text,
        },
        'roles': ['mentee'], // Set a default role
      };

      // Get a reference to the callable Cloud Function.
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('saveUserProfile');
      
      // Call the function and pass the data payload.
      await callable.call(userProfileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile information saved successfully!'),
            backgroundColor: appTheme.blue_gray_700,
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => InstitutionalVerificationScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}