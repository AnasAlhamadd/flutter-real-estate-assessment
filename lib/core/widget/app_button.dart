import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "Button / Primary / Rounded": primary pill, 54 px tall, fills the
/// width it is given.
class AppButton extends StatelessWidget {
  const AppButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusPill.r);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppSizes.buttonShadow,
      ),
      child: Material(
        color: ColorsApp.primary,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: AppSizes.buttonHeight.h,
              minWidth: double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontalPadding.w,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
