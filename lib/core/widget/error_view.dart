import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/error/failure_message.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Failure state with a translated message and a retry button.
/// Figma has no error frame, so it is built from tokens.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.screenHorizontalPadding.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              failure.messageKey,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium16,
            ),
            SizedBox(height: AppSizes.sectionGap.h),
            AppButton(
              label: context.tr(AppTextKeys.commonRetry),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
