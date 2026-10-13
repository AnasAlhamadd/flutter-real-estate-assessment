import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Stand-in for screens that are built in Phase 5.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.titleKey,
    this.messageKey = AppTextKeys.commonComingSoon,
    this.child,
    super.key,
  });

  final String titleKey;
  final String messageKey;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: CustomText(titleKey)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSizes.screenHorizontalPadding.w,
            vertical: AppSizes.screenHorizontalPadding.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(messageKey, textAlign: TextAlign.start),
              if (child != null) ...[
                SizedBox(height: AppSizes.screenHorizontalPadding.h),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
