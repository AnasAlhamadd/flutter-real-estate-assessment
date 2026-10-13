import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "Button" `1:4547`: white full-width pill with the Google logo.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusAuthButton.r);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppSizes.authButtonShadow,
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: ColorsApp.white,
          foregroundColor: ColorsApp.black01,
          side: const BorderSide(color: ColorsApp.primary4),
          shape: RoundedRectangleBorder(borderRadius: radius),
          minimumSize: const Size(double.infinity, AppSizes.minTapTarget),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.screenHorizontalPadding.w,
            vertical: AppSizes.authButtonVerticalPadding.h,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.authButtonIconGap.w,
          children: [
            const ExcludeSemantics(
              child: AppSvgIcon(
                ImagePath.google,
                size: AppSizes.authButtonIconSize,
              ),
            ),
            Flexible(
              child: CustomText(
                AppTextKeys.authGoogleButton,
                textAlign: TextAlign.center,
                style: AppTextStyles.authButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
