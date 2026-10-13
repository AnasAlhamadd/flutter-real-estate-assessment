import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_rating_text.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_stats.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/property_tag.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Title, category tag, rating and stats row (Figma `1:4274`).
class DetailsHeader extends StatelessWidget {
  const DetailsHeader({
    required this.property,
    this.reviewCount,
    this.extras,
    super.key,
  });

  final PropertyEntity property;

  /// `null` until the details (and their reviews) are loaded.
  final int? reviewCount;

  /// Beds, baths and area; `null` hides the stats row.
  final PropertyExtrasEntity? extras;

  /// The category slug as words: `home-decoration` → `home decoration`. Shown
  /// uppercase, so it reads like the API category name.
  static String categoryLabel(String slug) => slug.replaceAll('-', ' ');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText.plain(property.title, style: AppTextStyles.detailsTitle),
        SizedBox(height: AppSizes.detailsTitleRowGap.h),
        Wrap(
          spacing: AppSizes.detailsTagRatingGap.w,
          runSpacing: AppSizes.detailsTagRatingGap.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PropertyTag(label: categoryLabel(property.category)),
            _Rating(
              text: detailsRatingText(
                context,
                rating: property.rating,
                reviewCount: reviewCount,
              ),
            ),
          ],
        ),
        if (extras case final extras?) ...[
          SizedBox(height: AppSizes.detailsTitleRowGap.h),
          DetailsStats(extras: extras),
        ],
      ],
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSvgIcon(ImagePath.star, size: AppSizes.detailsRatingIconSize),
        SizedBox(width: AppSizes.detailsRatingIconGap.w),
        Flexible(
          child: CustomText.plain(text, style: AppTextStyles.detailsRating),
        ),
      ],
    );
  }
}
