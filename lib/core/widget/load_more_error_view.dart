import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/error/failure_message.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact failure below a list whose next page didn't load. The loaded
/// items stay above it. Figma has no error design, so it uses tokens.
class LoadMoreErrorView extends StatelessWidget {
  const LoadMoreErrorView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.gridVerticalGap.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            failure.messageKey,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyRegular14,
          ),
          Center(
            child: TextButton(
              onPressed: onRetry,
              child: CustomText(
                AppTextKeys.commonRetry,
                style: AppTextStyles.link,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
