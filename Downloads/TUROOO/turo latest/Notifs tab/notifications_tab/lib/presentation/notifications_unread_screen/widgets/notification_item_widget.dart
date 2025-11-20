import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';

class NotificationItemWidget extends StatelessWidget {
  final String profileImage;
  final String message;
  final String timestamp;
  final VoidCallback? onTap;

  NotificationItemWidget({
    Key? key,
    required this.profileImage,
    required this.message,
    required this.timestamp,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: appTheme.gray_400,
              width: 1.h,
            ),
          ),
        ),
        child: Row(
          spacing: 10.h,
          children: [
            CustomImageView(
              imagePath: profileImage,
              height: 40.h,
              width: 40.h,
              radius: BorderRadius.circular(20.h),
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: TextStyleHelper.instance.title16RegularFustat
                        .copyWith(height: 1.44),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    timestamp,
                    style: TextStyleHelper.instance.body12RegularFustat
                        .copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
