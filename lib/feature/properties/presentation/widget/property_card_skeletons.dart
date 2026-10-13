import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Loading placeholder with the size and corners of a `FeaturedPropertyCard`
/// (a full-bleed photo card).
class FeaturedPropertyCardSkeleton extends StatelessWidget {
  const FeaturedPropertyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SkeletonBox(
        width: AppSizes.featuredCardWidth.r,
        height: AppSizes.featuredCardHeight.r,
        radius: AppSizes.radiusFeaturedCard.r,
      ),
    );
  }
}

/// Loading placeholder laid out like a `PropertyGridCard`: same card
/// surface, image ratio, paddings and text line heights (at the current text
/// scale), so swapping in the real card doesn't move the page.
class PropertyGridCardSkeleton extends StatelessWidget {
  const PropertyGridCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusGridCard.r);
    final textRadius = AppSizes.radiusPill.r;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsApp.white,
        borderRadius: radius,
        boxShadow: AppSizes.cardShadow,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSizes.gridCardPaddingSide.w,
          AppSizes.gridCardPaddingTop.h,
          AppSizes.gridCardPaddingSide.w,
          AppSizes.gridCardPaddingBottom.h,
        ),
        child: AppShimmer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: AppSizes.gridImageWidth / AppSizes.gridImageHeight,
                child: SkeletonBox(radius: AppSizes.radiusImage.r),
              ),
              SizedBox(height: AppSizes.gridImageContentGap.h),
              SkeletonTextLine(
                style: AppTextStyles.gridTitle,
                widthFactor: 0.85,
                radius: textRadius,
              ),
              SizedBox(height: AppSizes.gridTitleLocationGap.h),
              SkeletonTextLine(
                style: AppTextStyles.gridLocation,
                widthFactor: 0.55,
                radius: textRadius,
              ),
              SizedBox(height: AppSizes.gridContentPriceGap.h),
              SkeletonTextLine(
                style: AppTextStyles.gridPrice,
                widthFactor: 0.4,
                radius: textRadius,
                minHeight: AppSizes.gridHeartSize.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
