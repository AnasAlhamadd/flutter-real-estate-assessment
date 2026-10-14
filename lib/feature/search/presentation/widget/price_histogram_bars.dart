import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "Bar Chart" `1:3982`: one Primary 10% bar per price bucket, as tall
/// as its share of the largest bucket. Empty buckets keep the 3 px baseline
/// of the design's shortest bar. Mirrors in RTL with the slider.
class PriceHistogramBars extends StatelessWidget {
  const PriceHistogramBars({required this.counts, super.key});

  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final height = AppSizes.filterHistogramHeight.h;
    final minHeight = AppSizes.filterHistogramMinBarHeight.h;
    final largest = counts.fold(0, math.max);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: AppSizes.filterHistogramBarGap.w,
        children: [
          for (final count in counts)
            Expanded(
              child: SizedBox(
                height: largest == 0
                    ? minHeight
                    : math.max(minHeight, height * count / largest),
                child: const ColoredBox(color: ColorsApp.primary10),
              ),
            ),
        ],
      ),
    );
  }
}
