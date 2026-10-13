import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Section title with an optional "See All" link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.onSeeAll, super.key});

  final String title;

  /// Hides the "See All" link when `null`.
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        if (onSeeAll != null) ...[
          SizedBox(width: AppSizes.chipGap.w),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(AppSizes.radiusSearchField.r),
            child: CustomText(
              AppTextKeys.commonSeeAll,
              style: AppTextStyles.link,
            ),
          ),
        ],
      ],
    );
  }
}
