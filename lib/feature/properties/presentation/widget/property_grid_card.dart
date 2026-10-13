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

/// Home "Our Recommendation" card (Figma `1:4473`). Takes the width of its
/// grid cell; the image keeps the Figma 159×154 ratio.
class PropertyGridCard extends StatelessWidget {
  const PropertyGridCard({
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
    final radius = BorderRadius.circular(AppSizes.radiusGridCard.r);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppSizes.cardShadow,
      ),
      child: Material(
        color: ColorsApp.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSizes.gridCardPaddingSide.w,
              AppSizes.gridCardPaddingTop.h,
              AppSizes.gridCardPaddingSide.w,
              AppSizes.gridCardPaddingBottom.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GridImage(property: property),
                SizedBox(height: AppSizes.gridImageContentGap.h),
                _GridDetails(
                  property: property,
                  location: property.locationLabel(categoryName: categoryName),
                  favoriteButton: favoriteButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridImage extends StatelessWidget {
  const _GridImage({required this.property});

  final PropertyEntity property;

  @override
  Widget build(BuildContext context) {
    final inset = RatingBadgeSize.medium.inset.r;
    return AspectRatio(
      aspectRatio: AppSizes.gridImageWidth / AppSizes.gridImageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            url: property.thumbnailUrl,
            borderRadius: BorderRadius.circular(AppSizes.radiusImage.r),
          ),
          PositionedDirectional(
            top: inset,
            end: inset,
            child: RatingBadge(
              rating: property.rating,
              size: RatingBadgeSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridDetails extends StatelessWidget {
  const _GridDetails({
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
          style: AppTextStyles.gridTitle,
        ),
        SizedBox(height: AppSizes.gridTitleLocationGap.h),
        Text(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.gridLocation,
        ),
        SizedBox(height: AppSizes.gridContentPriceGap.h),
        Row(
          children: [
            Expanded(
              child: Text(
                Formatters.price(property.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.gridPrice,
              ),
            ),
            ?favoriteButton,
          ],
        ),
      ],
    );
  }
}
