import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
// Make sure to change 'turo' to your actual package name if different, or use relative paths
import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import 'providers/mentor_registration_provider.dart';

class MentorStep2InstitutionalDetails extends StatefulWidget {
  const MentorStep2InstitutionalDetails({super.key});

  @override
  State<MentorStep2InstitutionalDetails> createState() =>
      _MentorStep2InstitutionalDetailsState();
}

class _MentorStep2InstitutionalDetailsState
    extends State<MentorStep2InstitutionalDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _institutionEmailController =
      TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<MentorRegistrationProvider>();
    _institutionController.text = provider.institutionName;
    _institutionEmailController.text = provider.institutionEmail;
    _jobTitleController.text = provider.jobTitle;
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _institutionEmailController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  String? _validateInstitutionEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your institutional email.';
    }
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  void _onNextPressed() {
    if (_formKey.currentState?.validate() != true) return;

    context.read<MentorRegistrationProvider>().updateInstitutionalInfo(
      institutionName: _institutionController.text,
      institutionEmail: _institutionEmailController.text,
      jobTitle: _jobTitleController.text,
    );

    context.read<MentorRegistrationProvider>().nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 100.h,
              width: 100.h,
              decoration: BoxDecoration(
                color: appTheme.blue_gray_700,
                borderRadius: BorderRadius.circular(50.h),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.buildingColumns,
                  size: 50.h,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              'Verify your Institution',
              style: TextStyleHelper.instance.title20SemiBoldFustat.copyWith(
                color: appTheme.gray_800,
                height: 1.45,
              ),
            ),
          ),
          Center(
            child: Text(
              'Please provide your official affiliation details. These will be reviewed by our Admins for verification.',
              style: TextStyleHelper.instance.body12RegularFustat.copyWith(
                color: appTheme.gray_800,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Institution Name:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _institutionController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your institution name.'
                      : null,
                  decoration: const InputDecoration(
                    hintText: 'Enter institution name',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2C6A64)),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                const Text(
                  'Institutional Email:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CustomEditText(
                  controller: _institutionEmailController,
                  placeholder: 'Enter institutional email',
                  validator: _validateInstitutionEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),

                const Text(
                  'Job Title:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CustomEditText(
                  controller: _jobTitleController,
                  placeholder: 'Enter your job title',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your job title.'
                      : null,
                ),

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Next',
                    onPressed: _onNextPressed,
                    backgroundColor: appTheme.blue_gray_700,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
