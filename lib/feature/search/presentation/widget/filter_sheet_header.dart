import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "Popup Title" `1:3972`: back (closes without applying), centered
/// "Filter", and "Reset".
///
/// The tap targets reach [overhang] past the Figma frame on every side, so
/// place the header with that much less padding than the content.
class FilterSheetHeader extends StatelessWidget {
  const FilterSheetHeader({required this.onReset, super.key});

  final VoidCallback onReset;

  /// How far the back button's tap target extends past its 32 px circle.
  static double get overhang =>
      (AppSizes.minTapTarget - AppSizes.filterBackButtonSize.r) / 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppBackButton.compact(),
          ),
        ),
        Expanded(
          flex: 2,
          child: Semantics(
            header: true,
            child: CustomText(
              AppTextKeys.commonFilter,
              style: AppTextStyles.bodyMedium16,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                padding: EdgeInsetsDirectional.only(end: overhang),
                minimumSize: const Size.square(AppSizes.minTapTarget),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: AlignmentDirectional.centerEnd,
                foregroundColor: AppTextStyles.filterReset.color,
              ),
              child: CustomText(
                AppTextKeys.filterReset,
                style: AppTextStyles.filterReset,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
