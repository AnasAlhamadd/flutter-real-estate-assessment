import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One Filter sheet section (Figma "Price Range" `1:3979`, "type" `1:4012`):
/// title, 16 px gap, content.
class FilterSection extends StatelessWidget {
  const FilterSection({required this.titleKey, required this.child, super.key});

  final String titleKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: CustomText(titleKey, style: AppTextStyles.filterSectionTitle),
        ),
        SizedBox(height: AppSizes.filterSectionTitleGap.h),
        child,
      ],
    );
  }
}
