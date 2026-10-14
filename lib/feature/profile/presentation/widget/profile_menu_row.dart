import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma Profile menu row (`1:3842`): 28 px icon, label and the chevron.
/// [value] (not in Figma) shows the current setting before the chevron.
///
/// The tap target reaches [overhang] above and below the 28 px row, so place
/// the row with that much less spacing around it.
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    required this.icon,
    required this.labelKey,
    required this.onTap,
    this.value,
    super.key,
  });

  final String icon;
  final String labelKey;

  /// Already translated.
  final String? value;
  final VoidCallback onTap;

  static double get overhang => math.max(
    0,
    (AppSizes.minTapTarget - AppSizes.profileMenuRowHeight.r) / 2,
  );

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: overhang),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: AppSizes.profileMenuRowHeight.r,
              ),
              child: _content(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final value = this.value;
    return Row(
      children: [
        AppSvgIcon(
          icon,
          size: AppSizes.languageIconSize,
          color: ColorsApp.black01,
        ),
        SizedBox(width: AppSizes.profileMenuIconGap.w),
        Expanded(
          child: CustomText(
            labelKey,
            style: AppTextStyles.profileMenuLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (value != null) ...[
          SizedBox(width: AppSizes.inlineTextGap.w),
          CustomText.plain(
            value,
            style: AppTextStyles.bodyRegular14,
            maxLines: 1,
          ),
        ],
        SizedBox(width: AppSizes.inlineTextGap.w),
        const AppSvgIcon(
          ImagePath.arrowRight,
          size: AppSizes.smallIconSize,
          color: ColorsApp.black01,
          matchTextDirection: true,
        ),
      ],
    );
  }
}
