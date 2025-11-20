import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';

class NotificationItemWidget extends StatelessWidget {
  final String imagePath;
  final String message;
  final String timestamp;
  final VoidCallback? onTap;

  NotificationItemWidget({
    Key? key,
    required this.imagePath,
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
          children: [
            CustomImageView(
              imagePath: imagePath,
              height: 40.h,
              width: 40.h,
              radius: BorderRadius.circular(20.h),
            ),
            SizedBox(width: 10.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyleHelper.instance.title16RegularFustat
                        .copyWith(height: 1.44),
                  ),
                  SizedBox(height: 4.h),
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
