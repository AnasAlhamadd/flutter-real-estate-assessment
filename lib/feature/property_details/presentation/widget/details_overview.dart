import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Overview" (Figma `1:4311`) with the API description.
class DetailsOverview extends StatelessWidget {
  const DetailsOverview({required String this.description, super.key});

  /// Skeleton lines in place of the description while it loads.
  const DetailsOverview.loading({super.key}) : description = null;

  final String? description;

  static const List<double> _skeletonLineWidths = [1, 1, 0.6];

  @override
  Widget build(BuildContext context) {
    final body = AppTextStyles.detailsBody;
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(body.fontSize!) * body.height!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          AppTextKeys.detailsOverview,
          style: AppTextStyles.sectionTitle,
        ),
        SizedBox(height: AppSizes.detailsOverviewGap.h),
        if (description case final text?)
          CustomText.plain(text, style: body)
        else
          Semantics(
            label: context.tr(AppTextKeys.commonLoading),
            child: ExcludeSemantics(
              child: AppShimmer(
                child: Column(
                  children: [
                    for (final width in _skeletonLineWidths)
                      SkeletonTextLine(
                        style: body.copyWith(height: 1),
                        widthFactor: width,
                        radius: AppSizes.radiusPill.r,
                        minHeight: lineHeight,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
