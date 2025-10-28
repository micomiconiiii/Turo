
import 'package:flutter/material.dart';
import 'package:turo/core/app_export.dart';
import 'package:turo/widgets/custom_button.dart';

class CredentialsAchievementsScreen extends StatefulWidget {
  @override
  _CredentialsAchievementsScreenState createState() =>
      _CredentialsAchievementsScreenState();
}

class _CredentialsAchievementsScreenState
    extends State<CredentialsAchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Credentials & Achievements"),
      ),
      body: SafeArea(
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
                    'Step 6 out of 6',
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(height: 1.5),
                  ),
                ],
              ),

              // ---- PROGRESS BAR ----
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  _buildProgressSegment(filled: true),
                  SizedBox(width: 2.h),
                  _buildProgressSegment(filled: true),
                ],
              ),

              SizedBox(height: 24.h),

              Center(
                child: Text(
                  'Credentials & Achievements',
                  style: TextStyleHelper.instance.title20SemiBoldFustat
                      .copyWith(color: appTheme.gray_800, height: 1.45),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Add Credentials",
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: 16.h),
              // Add role fields and button here
              Text(
                "Add Achievements",
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: 16.h),
              // Add certificate upload button here
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h, left: 20.h, right: 20.h),
          child: CustomButton(
            text: 'Continue',
            onPressed: () {
              // Navigate to the next screen
            },
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
}
