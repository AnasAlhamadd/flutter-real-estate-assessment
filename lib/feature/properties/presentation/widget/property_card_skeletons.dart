import 'dart:math' as math;

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
              _TextLine(
                style: AppTextStyles.gridTitle,
                widthFactor: 0.85,
                radius: textRadius,
              ),
              SizedBox(height: AppSizes.gridTitleLocationGap.h),
              _TextLine(
                style: AppTextStyles.gridLocation,
                widthFactor: 0.55,
                radius: textRadius,
              ),
              SizedBox(height: AppSizes.gridContentPriceGap.h),
              _TextLine(
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

/// A bar as tall as one line of [style] in the current font and text
/// scale, bottom-aligned in at least [minHeight] (the price row is as tall
/// as its heart).
class _TextLine extends StatelessWidget {
  const _TextLine({
    required this.style,
    required this.widthFactor,
    required this.radius,
    this.minHeight = 0,
  });

  final TextStyle style;
  final double widthFactor;
  final double radius;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final lineHeight = _lineHeight(context);
    return SizedBox(
      height: math.max(lineHeight, minHeight),
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: SkeletonBox(height: lineHeight, radius: radius),
        ),
      ),
    );
  }

  /// Measured like `Text` lays it out, so it matches the real card.
  double _lineHeight(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: ' ',
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }
}
