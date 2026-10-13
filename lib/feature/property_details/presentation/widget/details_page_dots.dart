import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Hero page dots (Figma `1:4240`): the current page is a 32 × 8 Primary
/// pill, the others 8 × 8 white dots.
class DetailsPageDots extends StatelessWidget {
  const DetailsPageDots({
    required this.count,
    required this.controller,
    super.key,
  });

  final int count;
  final PageController controller;

  static const Duration animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : animationDuration;
    return ExcludeSemantics(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final current = _currentPage();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < count; index++) ...[
                if (index > 0) SizedBox(width: AppSizes.detailsDotGap.r),
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOut,
                  width: index == current
                      ? AppSizes.detailsDotActiveWidth.r
                      : AppSizes.detailsDotSize.r,
                  height: AppSizes.detailsDotSize.r,
                  decoration: BoxDecoration(
                    color: index == current
                        ? ColorsApp.primary
                        : ColorsApp.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  int _currentPage() {
    if (!controller.hasClients || !controller.position.haveDimensions) {
      return controller.initialPage;
    }
    return (controller.page ?? 0).round().clamp(0, count - 1);
  }
}
