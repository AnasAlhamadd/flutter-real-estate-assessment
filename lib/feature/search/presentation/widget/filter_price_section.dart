import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_real_estate_assessment/core/widget/load_more_error_view.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_state.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/filter_section.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/price_range_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Price Range" over the full matching set: a skeleton while it loads, a
/// retry when it failed (categories still work), then the chart.
class FilterPriceSection extends StatelessWidget {
  const FilterPriceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FilterSection(
      titleKey: AppTextKeys.filterPriceRange,
      child: BlocBuilder<FilterCubit, FilterState>(
        buildWhen: (previous, current) =>
            previous.priceStatus != current.priceStatus ||
            previous.histogram != current.histogram ||
            previous.failure != current.failure ||
            previous.rangeStart != current.rangeStart ||
            previous.rangeEnd != current.rangeEnd,
        builder: (context, state) {
          final cubit = context.read<FilterCubit>();
          final histogram = state.histogram;
          if (state.priceStatus == RequestStatus.failure) {
            return LoadMoreErrorView(
              failure: state.failure!,
              onRetry: cubit.retry,
            );
          }
          if (histogram == null) return const _PriceSkeleton();
          return PriceRangeChart(
            histogram: histogram,
            start: state.rangeStart,
            end: state.rangeEnd,
            onChanged: histogram.canSelectRange ? cubit.setPriceRange : null,
          );
        },
      ),
    );
  }
}

/// As tall as the chart: bars, half a thumb, the label gap and one label.
class _PriceSkeleton extends StatelessWidget {
  const _PriceSkeleton();

  @override
  Widget build(BuildContext context) {
    final chartHeight =
        AppSizes.filterHistogramHeight.h +
        AppSizes.filterSliderThumbSize.r / 2 +
        AppSizes.filterPriceLabelGap.h;
    return Semantics(
      label: context.tr(AppTextKeys.commonLoading),
      excludeSemantics: true,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: chartHeight, radius: AppSizes.radiusImage.r),
            SkeletonTextLine(
              style: AppTextStyles.filterPriceLabel,
              widthFactor: 1,
              radius: AppSizes.radiusPill.r,
            ),
          ],
        ),
      ),
    );
  }
}
