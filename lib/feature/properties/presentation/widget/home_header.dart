import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home header (Figma `1:4448`). There is no signed-in user (Q11), so the
/// photo becomes a neutral avatar and the name a welcome line. The bell is
/// hidden because no notifications feature exists (Q13).
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.now, super.key});

  /// Picks the greeting; injected so tests don't depend on the clock.
  final DateTime now;

  /// Morning 05:00–11:59, afternoon 12:00–16:59, evening otherwise.
  static String greetingKeyFor(DateTime time) => switch (time.hour) {
    >= 5 && < 12 => AppTextKeys.homeGoodMorning,
    >= 12 && < 17 => AppTextKeys.homeGoodAfternoon,
    _ => AppTextKeys.homeGoodEvening,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _GuestAvatar(),
        SizedBox(width: AppSizes.homeAvatarTextGap.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                greetingKeyFor(now),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.homeGreeting,
              ),
              CustomText(
                AppTextKeys.homeWelcomeGuest,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestAvatar extends StatelessWidget {
  const _GuestAvatar();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: AppSizes.homeAvatarSize.r,
        height: AppSizes.homeAvatarSize.r,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: ColorsApp.greyscale400,
          shape: BoxShape.circle,
        ),
        child: const AppSvgIcon(
          ImagePath.profileLight,
          size: AppSizes.iconSize,
          color: ColorsApp.white,
        ),
      ),
    );
  }
}
