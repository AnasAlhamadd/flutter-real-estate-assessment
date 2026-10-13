import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/core/widget/rating_badge.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_location_label.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home "Featured" card: full-bleed image with a bottom gradient, rating
/// badge, title, location and price (Figma `1:4470`).
///
/// Sized with `.r` (the smaller of the width and height scale), so the card
/// keeps the Figma 250×340 proportions without outgrowing short landscape
/// screens or stretching on tablets.
class FeaturedPropertyCard extends StatelessWidget {
  const FeaturedPropertyCard({
    required this.property,
    required this.onTap,
    this.categoryName,
    this.favoriteButton,
    super.key,
  });

  final PropertyEntity property;
  final VoidCallback onTap;
  final String? categoryName;

  /// Optional heart, normally a `FavoriteButton`. It is centered on the
  /// Figma heart position (end of the price row), so its tap area can be
  /// larger than the icon without moving the text.
  final Widget? favoriteButton;

  @override
  Widget build(BuildContext context) {
    final badgeInset = RatingBadgeSize.large.inset;
    const tapRadius = AppSizes.minTapTarget / 2;
    final heartRadius = AppSizes.featuredHeartSize.r / 2;
    return SizedBox(
      width: AppSizes.featuredCardWidth.r,
      height: AppSizes.featuredCardHeight.r,
      child: Material(
        color: ColorsApp.greyscale400,
        borderRadius: BorderRadius.circular(AppSizes.radiusFeaturedCard.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: property.thumbnailUrl),
              const _BottomGradient(),
              PositionedDirectional(
                top: badgeInset.r,
                end: badgeInset.r,
                child: RatingBadge(
                  rating: property.rating,
                  size: RatingBadgeSize.large,
                ),
              ),
              PositionedDirectional(
                start: AppSizes.featuredContentHorizontalPadding.r,
                end: AppSizes.featuredContentHorizontalPadding.r,
                bottom: AppSizes.featuredContentBottomPadding.r,
                child: _FeaturedContent(
                  property: property,
                  location: property.locationLabel(categoryName: categoryName),
                  hasFavoriteButton: favoriteButton != null,
                ),
              ),
              if (favoriteButton case final button?)
                PositionedDirectional(
                  end:
                      AppSizes.featuredContentHorizontalPadding.r +
                      heartRadius -
                      tapRadius,
                  bottom:
                      AppSizes.featuredContentBottomPadding.r +
                      heartRadius -
                      tapRadius,
                  child: button,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: AppSizes.featuredGradientFraction,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorsApp.featuredGradientStart,
                ColorsApp.featuredGradientEnd,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedContent extends StatelessWidget {
  const _FeaturedContent({
    required this.property,
    required this.location,
    required this.hasFavoriteButton,
  });

  final PropertyEntity property;
  final String location;
  final bool hasFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText.plain(
          property.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.featuredTitle,
        ),
        SizedBox(height: AppSizes.featuredTitleLocationGap.h),
        CustomText.plain(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.featuredLocation,
        ),
        SizedBox(height: AppSizes.featuredLocationPriceGap.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: CustomText.plain(
                Formatters.price(property.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.featuredPrice,
              ),
            ),
            if (hasFavoriteButton) ...[
              SizedBox(width: AppSizes.inlineTextGap.w),
              SizedBox.square(dimension: AppSizes.featuredHeartSize.r),
            ],
          ],
        ),
      ],
    );
  }
}
