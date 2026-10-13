import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Explore header (Figma `1:4120`): back button `1:4161`, centered title.
/// The bell `1:4165` is hidden (Q13); an empty slot of the same size keeps
/// the title centered on the screen.
class SearchHeader extends StatelessWidget {
  const SearchHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final gap = AppSizes.inlineTextGap.w;
    return Row(
      children: [
        AppBackButton(onPressed: onBack),
        SizedBox(width: gap),
        Expanded(
          child: Semantics(
            header: true,
            child: CustomText(
              AppTextKeys.exploreTitle,
              style: AppTextStyles.searchHeaderTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(width: gap),
        SizedBox.square(dimension: AppSizes.iconButtonSize.r),
      ],
    );
  }
}
