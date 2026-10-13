import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "Tag / Inverted / Info" (`1:4277`): uppercase Primary label on a
/// Primary 4% pill.
class PropertyTag extends StatelessWidget {
  const PropertyTag({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsApp.primary4,
        borderRadius: BorderRadius.circular(AppSizes.radiusTag.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.detailsTagPaddingHorizontal.w,
          vertical: AppSizes.detailsTagPaddingVertical.h,
        ),
        child: CustomText.plain(
          label,
          upperCase: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.detailsTag,
        ),
      ),
    );
  }
}
