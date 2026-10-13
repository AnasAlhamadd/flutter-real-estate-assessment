import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Eyebrow, headline and subtitle of the Auth screen (Figma `1:4543`).
class AuthIntro extends StatelessWidget {
  const AuthIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.authTextGap.h,
      children: [
        CustomText(
          AppTextKeys.authWelcome,
          upperCase: true,
          textAlign: TextAlign.center,
          style: AppTextStyles.authEyebrow,
        ),
        const _Headline(),
        CustomText(
          AppTextKeys.authSubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubtitle,
        ),
      ],
    );
  }
}

/// The highlighted part comes last in both languages, so it is appended to
/// the headline after a space.
class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: context.tr(AppTextKeys.authHeadline)),
            const TextSpan(text: ' '),
            TextSpan(
              text: context.tr(AppTextKeys.authHeadlineHighlight),
              style: const TextStyle(color: ColorsApp.primary),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: AppTextStyles.authHeadline,
      ),
    );
  }
}
