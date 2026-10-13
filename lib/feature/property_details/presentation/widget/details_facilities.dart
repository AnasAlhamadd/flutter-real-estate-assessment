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

/// Facilities (Figma `1:4314`): rows of four icon circles with a one-line
/// label, ellipsized like Figma's "Swimming...".
class DetailsFacilities extends StatelessWidget {
  const DetailsFacilities({required this.facilities, super.key});

  /// Not empty.
  final List<PropertyFacility> facilities;

  static ({String icon, String label}) contentOf(PropertyFacility facility) =>
      switch (facility) {
        PropertyFacility.carParking => (
          icon: ImagePath.facilityCarParking,
          label: AppTextKeys.facilityCarParking,
        ),
        PropertyFacility.swimmingPool => (
          icon: ImagePath.facilitySwimmingPool,
          label: AppTextKeys.facilitySwimmingPool,
        ),
        PropertyFacility.gym => (
          icon: ImagePath.facilityGym,
          label: AppTextKeys.facilityGym,
        ),
        PropertyFacility.restaurant => (
          icon: ImagePath.facilityRestaurant,
          label: AppTextKeys.facilityRestaurant,
        ),
        PropertyFacility.wifi => (
          icon: ImagePath.facilityWifi,
          label: AppTextKeys.facilityWifi,
        ),
        PropertyFacility.petCenter => (
          icon: ImagePath.facilityPetCenter,
          label: AppTextKeys.facilityPetCenter,
        ),
        PropertyFacility.sportCenter => (
          icon: ImagePath.facilitySportCenter,
          label: AppTextKeys.facilitySportCenter,
        ),
        PropertyFacility.laundry => (
          icon: ImagePath.facilityLaundry,
          label: AppTextKeys.facilityLaundry,
        ),
      };

  @override
  Widget build(BuildContext context) {
    const perRow = AppSizes.detailsFacilitiesPerRow;
    final rowCount = (facilities.length / perRow).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          AppTextKeys.detailsFacilities,
          style: AppTextStyles.sectionTitle,
        ),
        for (var row = 0; row < rowCount; row++) ...[
          SizedBox(
            height: row == 0
                ? AppSizes.detailsFacilitiesTitleGap.h
                : AppSizes.detailsFacilitiesRowGap.h,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var column = 0; column < perRow; column++) ...[
                if (column > 0) SizedBox(width: AppSizes.detailsFacilityGap.w),
                Expanded(
                  child: row * perRow + column < facilities.length
                      ? _Facility(facility: facilities[row * perRow + column])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Facility extends StatelessWidget {
  const _Facility({required this.facility});

  final PropertyFacility facility;

  @override
  Widget build(BuildContext context) {
    final content = DetailsFacilities.contentOf(facility);
    return Column(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: ColorsApp.primary4,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.detailsFacilityIconPadding.r),
            child: AppSvgIcon(
              content.icon,
              size: AppSizes.detailsFacilityIconSize,
              color: ColorsApp.primary,
            ),
          ),
        ),
        SizedBox(height: AppSizes.detailsFacilityGap.h),
        CustomText(
          content.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.facilityLabel,
        ),
      ],
    );
  }
}
