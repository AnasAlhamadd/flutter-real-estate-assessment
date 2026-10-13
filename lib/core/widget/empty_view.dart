import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Empty state. Figma has no empty frame, so it is built from tokens.
class EmptyView extends StatelessWidget {
  const EmptyView({this.messageKey = AppTextKeys.commonEmpty, super.key});

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.screenHorizontalPadding.w),
        child: CustomText(
          messageKey,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyRegular14,
        ),
      ),
    );
  }
}
