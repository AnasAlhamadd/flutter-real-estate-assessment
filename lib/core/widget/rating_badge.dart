import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Badge sizes from Figma: featured (14/12), grid (10/10), list (8/8)
/// star/text sizes.
enum RatingBadgeSize {
  large(
    iconSize: 14,
    paddingHorizontal: AppSizes.badgeLargePaddingHorizontal,
    paddingVertical: AppSizes.badgePaddingVertical,
    gap: AppSizes.badgeLargeGap,
    inset: AppSizes.badgeLargeInset,
  ),
  medium(
    iconSize: 10,
    paddingHorizontal: AppSizes.badgeMediumPaddingHorizontal,
    paddingVertical: AppSizes.badgePaddingVertical,
    gap: AppSizes.badgeMediumGap,
    inset: AppSizes.badgeMediumInset,
  ),
  small(
    iconSize: 8,
    paddingHorizontal: AppSizes.badgeSmallPaddingHorizontal,
    paddingVertical: AppSizes.badgeSmallPaddingVertical,
    gap: AppSizes.badgeSmallGap,
    inset: AppSizes.badgeSmallInset,
  );

  const RatingBadgeSize({
    required this.iconSize,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.gap,
    required this.inset,
  });

  final double iconSize;
  final double paddingHorizontal;
  final double paddingVertical;
  final double gap;

  /// Distance from the top and end edges of the image it sits on.
  final double inset;

  TextStyle get textStyle => switch (this) {
    RatingBadgeSize.large => AppTextStyles.badgeLarge,
    RatingBadgeSize.medium => AppTextStyles.badgeMedium,
    RatingBadgeSize.small => AppTextStyles.badgeSmall,
  };
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({required this.rating, required this.size, super.key});

  final double rating;
  final RatingBadgeSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.paddingHorizontal.w,
        vertical: size.paddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: ColorsApp.badgeBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
        boxShadow: AppSizes.badgeShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(ImagePath.star, size: size.iconSize),
          SizedBox(width: size.gap.w),
          Text(
            Formatters.rating(rating),
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: size.textStyle,
          ),
        ],
      ),
    );
  }
}
