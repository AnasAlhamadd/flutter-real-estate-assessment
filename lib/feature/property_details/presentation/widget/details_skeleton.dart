import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Loading placeholder for Details opened without a listing item (e.g. a
/// deep link): the hero, title and tag row shapes. Figma has no loading
/// design, so it reuses the app's shimmer.
class DetailsSkeleton extends StatelessWidget {
  const DetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final textRadius = AppSizes.radiusPill.r;
    return Semantics(
      label: context.tr(AppTextKeys.commonLoading),
      child: ExcludeSemantics(
        child: AppShimmer(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SkeletonBox(height: AppSizes.detailsHeroHeight.r),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.screenHorizontalPadding.w,
                  vertical: AppSizes.detailsBodyVerticalPadding.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkeletonTextLine(
                      style: AppTextStyles.detailsTitle,
                      widthFactor: 0.7,
                      radius: textRadius,
                    ),
                    SizedBox(height: AppSizes.detailsTitleRowGap.h),
                    SkeletonTextLine(
                      style: AppTextStyles.detailsRating,
                      widthFactor: 0.5,
                      radius: textRadius,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
