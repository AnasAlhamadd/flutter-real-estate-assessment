import 'dart:math' as math;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_page_dots.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Details hero (Figma `1:4237`) as a stretchy [SliverAppBar]: swipeable
/// photos, page dots when there is more than one photo, and [topBar] on top.
///
/// Pulling down past the top zooms the photo; scrolling the hero away blurs
/// it. Both follow the hero's laid-out height, so they track the finger
/// exactly. Overscroll needs bouncing physics on the scroll view.
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
    return SliverAppBar(
      primary: false,
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
      expandedHeight: AppSizes.detailsHeroHeight.r,
      stretch: true,
      backgroundColor: ColorsApp.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      excludeHeaderSemantics: true,
      flexibleSpace: _HeroSpace(
        imageUrls: imageUrls,
        controller: controller,
        topBar: topBar,
      ),
    );
  }
}

/// The flexible space: the hero at its expanded height, moved up as it
/// scrolls away and stretched when pulled down.
class _HeroSpace extends StatelessWidget {
  const _HeroSpace({
    required this.imageUrls,
    required this.controller,
    required this.topBar,
  });

  final List<String?> imageUrls;
  final PageController controller;
  final Widget topBar;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final expanded = settings?.maxExtent ?? height;
        if (expanded <= 0) return const SizedBox.shrink();
        final pulled = math.max(0.0, height - expanded);
        final scrolledAway = math.max(0.0, expanded - height);
        final blur = AppSizes.detailsHeroMaxBlur * scrolledAway / expanded;
        return Stack(
          children: [
            Positioned(
              top: -scrolledAway,
              left: 0,
              right: 0,
              height: expanded + pulled,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: expanded,
                    child: ImageFiltered(
                      enabled: blur > 0,
                      imageFilter: ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                        tileMode: TileMode.clamp,
                      ),
                      child: Transform.scale(
                        scale: 1 + pulled / expanded,
                        alignment: Alignment.topCenter,
                        child: _HeroPhotos(
                          imageUrls: imageUrls,
                          controller: controller,
                        ),
                      ),
                    ),
                  ),
                  const _BottomGradient(),
                  if (imageUrls.length > 1)
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      bottom: AppSizes.detailsDotsBottom.r,
                      child: Center(
                        child: DetailsPageDots(
                          count: imageUrls.length,
                          controller: controller,
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    top: 0,
                    start: 0,
                    end: 0,
                    child: topBar,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroPhotos extends StatelessWidget {
  const _HeroPhotos({required this.imageUrls, required this.controller});

  final List<String?> imageUrls;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final count = imageUrls.length;
    return PageView.builder(
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
    );
  }
}

/// Keeps the white page dots readable on light photos.
class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: AppSizes.detailsHeroGradientHeight.r,
      child: const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ColorsApp.heroGradientStart, ColorsApp.overlay],
            ),
          ),
        ),
      ),
    );
  }
}
