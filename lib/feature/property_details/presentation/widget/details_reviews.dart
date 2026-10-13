import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/section_header.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_rating_text.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/review_tile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reviews (Figma `1:4400`): rating summary and the first review, like
/// Figma. "See All" shows the other reviews in place and then disappears.
class DetailsReviews extends StatefulWidget {
  const DetailsReviews({
    required this.rating,
    required this.reviews,
    required this.now,
    super.key,
  });

  final double rating;

  /// Not empty.
  final List<ReviewEntity> reviews;
  final DateTime now;

  @override
  State<DetailsReviews> createState() => _DetailsReviewsState();
}

class _DetailsReviewsState extends State<DetailsReviews> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final reviews = widget.reviews;
    final canExpand = !_expanded && reviews.length > 1;
    final shown = _expanded ? reviews : reviews.take(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          leading: Padding(
            padding: EdgeInsetsDirectional.only(
              end: AppSizes.detailsReviewsStarGap.w,
            ),
            child: const AppSvgIcon(
              ImagePath.star,
              size: AppSizes.detailsReviewsStarSize,
            ),
          ),
          title: detailsRatingText(
            context,
            rating: widget.rating,
            reviewCount: reviews.length,
          ),
          onSeeAll: canExpand ? () => setState(() => _expanded = true) : null,
        ),
        for (final review in shown) ...[
          SizedBox(height: AppSizes.detailsReviewsGap.h),
          ReviewTile(review: review, now: widget.now),
        ],
      ],
    );
  }
}
