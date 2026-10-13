import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/core/widget/rating_badge.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_location_label.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home "Featured" card: full-bleed image with a bottom gradient, rating
/// badge, title, location and price (Figma `1:4470`).
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

  /// Optional heart (Q8). Nothing is shown when `null`.
  final Widget? favoriteButton;

  @override
  Widget build(BuildContext context) {
    final badgeInset = RatingBadgeSize.large.inset;
    return SizedBox(
      width: AppSizes.featuredCardWidth.w,
      child: AspectRatio(
        aspectRatio: AppSizes.featuredCardWidth / AppSizes.featuredCardHeight,
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
                  start: AppSizes.featuredContentHorizontalPadding.w,
                  end: AppSizes.featuredContentHorizontalPadding.w,
                  bottom: AppSizes.featuredContentBottomPadding.h,
                  child: _FeaturedContent(
                    property: property,
                    location: property.locationLabel(
                      categoryName: categoryName,
                    ),
                    favoriteButton: favoriteButton,
                  ),
                ),
              ],
            ),
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
    this.favoriteButton,
  });

  final PropertyEntity property;
  final String location;
  final Widget? favoriteButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          property.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.featuredTitle,
        ),
        SizedBox(height: AppSizes.featuredTitleLocationGap.h),
        Text(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.featuredLocation,
        ),
        SizedBox(height: AppSizes.featuredLocationPriceGap.h),
        Row(
          children: [
            Expanded(
              child: Text(
                Formatters.price(property.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.featuredPrice,
              ),
            ),
            ?favoriteButton,
          ],
        ),
      ],
    );
  }
}
