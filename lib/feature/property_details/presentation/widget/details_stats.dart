import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Beds, baths and area (Figma `1:4281`). Wraps onto a second line when
/// the three don't fit (narrow screens, large text).
class DetailsStats extends StatelessWidget {
  const DetailsStats({required this.extras, super.key});

  final PropertyExtrasEntity extras;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.detailsStatsGap.w,
      runSpacing: AppSizes.detailsStatLabelGap.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Stat(
          icon: ImagePath.statBed,
          label: context.plural(AppTextKeys.detailsBeds, extras.bedrooms),
        ),
        _Stat(
          icon: ImagePath.statBath,
          label: context.plural(AppTextKeys.detailsBaths, extras.bathrooms),
        ),
        _Stat(
          icon: ImagePath.statArea,
          label: context.tr(
            AppTextKeys.detailsArea,
            namedArgs: {'area': '${extras.areaSqft}'},
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: ColorsApp.primary4,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.detailsStatIconPadding.r),
            child: AppSvgIcon(
              icon,
              size: AppSizes.detailsStatIconSize,
              color: ColorsApp.primary,
            ),
          ),
        ),
        SizedBox(width: AppSizes.detailsStatLabelGap.w),
        Flexible(
          child: CustomText.plain(label, style: AppTextStyles.detailsStat),
        ),
      ],
    );
  }
}
