import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "Tab" chip: primary fill when selected, primary 4% with a primary
/// 10% border otherwise.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusChip.r),
      side: selected
          ? BorderSide.none
          : const BorderSide(color: ColorsApp.primary10),
    );
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? ColorsApp.primary : ColorsApp.primary4,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.chipHorizontalPadding.w,
              vertical: AppSizes.chipVerticalPadding.h,
            ),
            child: CustomText.plain(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selected
                  ? AppTextStyles.chipActive
                  : AppTextStyles.chipInactive,
            ),
          ),
        ),
      ),
    );
  }
}
