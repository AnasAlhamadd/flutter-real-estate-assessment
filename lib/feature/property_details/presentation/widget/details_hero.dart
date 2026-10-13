import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_page_dots.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Details hero (Figma `1:4237`): swipeable photos, page dots when there is
/// more than one photo, and [topBar] on top.
class DetailsHero extends StatelessWidget {
  const DetailsHero({
    required this.imageUrls,
    required this.controller,
    required this.topBar,
    super.key,
  });

  /// At least one entry; `null` shows the image placeholder.
  final List<String?> imageUrls;
  final PageController controller;
  final Widget topBar;

  @override
  Widget build(BuildContext context) {
    final count = imageUrls.length;
    return SizedBox(
      height: AppSizes.detailsHeroHeight.r,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: controller,
              itemCount: count,
              itemBuilder: (context, index) => Semantics(
                image: true,
                label: context.tr(
                  AppTextKeys.detailsImagePosition,
                  namedArgs: {'index': '${index + 1}', 'total': '$count'},
                ),
                child: AppNetworkImage(url: imageUrls[index]),
              ),
            ),
          ),
          if (count > 1)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: AppSizes.detailsDotsBottom.r,
              child: Center(
                child: DetailsPageDots(count: count, controller: controller),
              ),
            ),
          PositionedDirectional(top: 0, start: 0, end: 0, child: topBar),
        ],
      ),
    );
  }
}
