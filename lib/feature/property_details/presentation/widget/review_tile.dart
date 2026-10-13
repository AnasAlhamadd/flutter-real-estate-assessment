import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/utils/relative_time.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One review (Figma `1:4406`): reviewer, comment, likes and how long ago
/// it was written. The API has no reviewer photo (Q4), so the avatar shows
/// initials.
class ReviewTile extends StatelessWidget {
  const ReviewTile({
    required this.review,
    required this.now,
    this.likes,
    super.key,
  });

  final ReviewEntity review;
  final DateTime now;

  /// Display only; `null` hides the heart and count.
  final int? likes;

  /// First letters of the first two words, e.g. "John Doe" → "JD".
  static String initialsOf(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word.characters.first.toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: AppSizes.detailsReviewContentGap.h);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _ReviewerAvatar(initials: initialsOf(review.reviewerName)),
            SizedBox(width: AppSizes.detailsReviewAvatarGap.w),
            Expanded(
              child: CustomText.plain(
                review.reviewerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.reviewerName,
              ),
            ),
          ],
        ),
        if (review.comment.trim().isNotEmpty) ...[
          gap,
          CustomText.plain(review.comment, style: AppTextStyles.detailsBody),
        ],
        if (likes != null || review.date != null) ...[
          gap,
          Row(
            children: [
              if (likes case final likes?) _ReviewLikes(likes: likes),
              const Spacer(),
              if (review.date case final date?)
                CustomText.plain(
                  _timeAgo(context, RelativeTimes.between(date, now)),
                  style: AppTextStyles.reviewTime,
                ),
            ],
          ),
        ],
      ],
    );
  }

  static String _timeAgo(BuildContext context, RelativeTime time) =>
      switch (time.unit) {
        RelativeTimeUnit.justNow => context.tr(AppTextKeys.timeJustNow),
        RelativeTimeUnit.minutes => context.plural(
          AppTextKeys.timeMinutesAgo,
          time.value,
        ),
        RelativeTimeUnit.hours => context.plural(
          AppTextKeys.timeHoursAgo,
          time.value,
        ),
        RelativeTimeUnit.days => context.plural(
          AppTextKeys.timeDaysAgo,
          time.value,
        ),
        RelativeTimeUnit.months => context.plural(
          AppTextKeys.timeMonthsAgo,
          time.value,
        ),
        RelativeTimeUnit.years => context.plural(
          AppTextKeys.timeYearsAgo,
          time.value,
        ),
      };
}

/// Heart and count (Figma `1:4415`), not tappable.
class _ReviewLikes extends StatelessWidget {
  const _ReviewLikes({required this.likes});

  final int likes;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.plural(AppTextKeys.detailsReviewLikes, likes),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSvgIcon(
            ImagePath.heart,
            size: AppSizes.detailsReviewLikeIconSize,
            color: ColorsApp.primary,
          ),
          SizedBox(width: AppSizes.detailsReviewLikeGap.w),
          CustomText.plain('$likes', style: AppTextStyles.reviewLikes),
        ],
      ),
    );
  }
}

/// Neutral avatar like the Home guest avatar (Greyscale/400, white content).
class _ReviewerAvatar extends StatelessWidget {
  const _ReviewerAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final size = AppSizes.detailsReviewAvatarSize.r;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: ColorsApp.greyscale400,
          shape: BoxShape.circle,
        ),
        child: initials.isEmpty
            ? const AppSvgIcon(
                ImagePath.profileLight,
                size: AppSizes.smallIconSize,
                color: ColorsApp.white,
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: CustomText.plain(
                  initials,
                  maxLines: 1,
                  style: AppTextStyles.reviewerInitials,
                ),
              ),
      ),
    );
  }
}
