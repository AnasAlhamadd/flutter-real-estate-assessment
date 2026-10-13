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

/// Explore result card (Figma `1:4170`): square image, two-line title,
/// location and price.
class PropertyListCard extends StatelessWidget {
  const PropertyListCard({
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
    final radius = BorderRadius.circular(AppSizes.radiusListCard.r);
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
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: AppSizes.listCardHeight.h),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSizes.listCardPaddingStart.w,
                AppSizes.listCardPaddingVertical.h,
                AppSizes.listCardPaddingEnd.w,
                AppSizes.listCardPaddingVertical.h,
              ),
              child: Row(
                children: [
                  _ListImage(property: property),
                  SizedBox(width: AppSizes.listImageContentGap.w),
                  Expanded(
                    child: _ListDetails(
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
      ),
    );
  }
}

class _ListImage extends StatelessWidget {
  const _ListImage({required this.property});

  final PropertyEntity property;

  @override
  Widget build(BuildContext context) {
    final inset = RatingBadgeSize.small.inset.r;
    return SizedBox.square(
      dimension: AppSizes.listImageSize.r,
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
              size: RatingBadgeSize.small,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListDetails extends StatelessWidget {
  const _ListDetails({
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                property.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.listTitle,
              ),
            ),
            ?favoriteButton,
          ],
        ),
        SizedBox(height: AppSizes.listTitleLocationGap.h),
        _LocationPriceRow(
          location: location,
          price: Formatters.price(property.price),
        ),
      ],
    );
  }
}

/// Location fills the row; the price keeps its natural width at the end and
/// only ellipsizes past [_maxPriceShare] of the row.
class _LocationPriceRow extends StatelessWidget {
  const _LocationPriceRow({required this.location, required this.price});

  static const double _maxPriceShare = 0.6;

  final String location;
  final String price;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.listLocation,
            ),
          ),
          SizedBox(width: AppSizes.inlineTextGap.w),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * _maxPriceShare,
            ),
            child: Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.listPrice,
            ),
          ),
        ],
      ),
    );
  }
}
