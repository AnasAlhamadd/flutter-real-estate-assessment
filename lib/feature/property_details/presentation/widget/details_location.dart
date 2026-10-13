import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Location (Figma `1:4380`): address line and the static map.
class DetailsLocation extends StatelessWidget {
  const DetailsLocation({required this.address, super.key});

  /// English data like the API titles, so it stays left-to-right.
  final String address;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: AppSizes.detailsLocationGap.h);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          AppTextKeys.detailsLocation,
          style: AppTextStyles.sectionTitle,
        ),
        gap,
        Row(
          children: [
            const AppSvgIcon(
              ImagePath.locationBold,
              size: AppSizes.detailsLocationIconSize,
              color: ColorsApp.primary,
            ),
            SizedBox(width: AppSizes.detailsLocationIconGap.w),
            Flexible(
              child: CustomText.plain(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
                style: AppTextStyles.detailsAddress,
              ),
            ),
          ],
        ),
        gap,
        const DetailsMap(),
      ],
    );
  }
}
