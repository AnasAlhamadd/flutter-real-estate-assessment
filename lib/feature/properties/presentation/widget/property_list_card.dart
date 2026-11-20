import 'dart:math' as math;

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

/// Explore result card (Figma `1:4170`): square image, two-line title and
/// location, then an end column with the heart on top and the price at the
/// bottom.
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

  /// Optional heart, normally a `FavoriteButton`. It is centered on the
  /// Figma heart (top of the end column), so its tap area can be larger
  /// than the icon without moving the text.
  final Widget? favoriteButton;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusListCard.r);
    const tapRadius = AppSizes.minTapTarget / 2;
    final heartRadius = AppSizes.listHeartSize.r / 2;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppSizes.cardShadow,
      ),
      child: Material(
        color: ColorsApp.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: AppSizes.listCardHeight.h,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    AppSizes.listCardPaddingStart.w,
                    AppSizes.listCardPaddingVertical.h,
                    AppSizes.listCardPaddingEnd.w,
                    AppSizes.listCardPaddingVertical.h,
                  ),
                  child: _ListContent(
                    property: property,
                    location: property.locationLabel(
                      categoryName: categoryName,
                    ),
                    hasFavoriteButton: favoriteButton != null,
                  ),
                ),
              ),
            ),
            if (favoriteButton case final button?)
              PositionedDirectional(
                top:
                    AppSizes.listCardPaddingVertical.h +
                    AppSizes.listEndColumnPadding.h +
                    heartRadius -
                    tapRadius,
                end: AppSizes.listCardPaddingEnd.w + heartRadius - tapRadius,
                child: button,
              ),
          ],
        ),
      ),
    );
  }
}

/// The end column keeps its natural width (at least the Figma 54) and only
/// ellipsizes the price past [_maxPriceShare] of the row.
class _ListContent extends StatelessWidget {
  const _ListContent({
    required this.property,
    required this.location,
    required this.hasFavoriteButton,
  });

  static const double _maxPriceShare = 0.4;

  final PropertyEntity property;
  final String location;
  final bool hasFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxEndWidth = constraints.maxWidth * _maxPriceShare;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _ListImage(property: property)),
              SizedBox(width: AppSizes.listImageContentGap.w),
              Expanded(
                child: _TitleAndLocation(
                  title: property.title,
                  location: location,
                ),
              ),
              SizedBox(width: AppSizes.listContentEndGap.w),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: math.min(
                    AppSizes.listEndColumnMinWidth.w,
                    maxEndWidth,
                  ),
                  maxWidth: maxEndWidth,
                ),
                child: _HeartAndPrice(
                  price: Formatters.price(property.price),
                  hasFavoriteButton: hasFavoriteButton,
                ),
              ),
            ],
          ),
        );
      },
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

class _TitleAndLocation extends StatelessWidget {
  const _TitleAndLocation({required this.title, required this.location});

  final String title;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText.plain(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.listTitle,
        ),
        SizedBox(height: AppSizes.listTitleLocationGap.h),
        CustomText.plain(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.listLocation,
        ),
      ],
    );
  }
}

/// The heart slot is empty space: the card draws the button over it.
class _HeartAndPrice extends StatelessWidget {
  const _HeartAndPrice({required this.price, required this.hasFavoriteButton});

  final String price;
  final bool hasFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.listEndColumnPadding.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasFavoriteButton)
            SizedBox.square(dimension: AppSizes.listHeartSize.r)
          else
            const SizedBox.shrink(),
          CustomText.plain(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.listPrice,
          ),
        ],
      ),
    );
  }
}
