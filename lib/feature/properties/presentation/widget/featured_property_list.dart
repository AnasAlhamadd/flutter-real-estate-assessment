import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal row of Featured cards (Figma `1:4469`). It starts from the
/// reading side, so Arabic scrolls from the right.
class FeaturedPropertyList extends StatelessWidget {
  const FeaturedPropertyList({
    required this.properties,
    required this.onTap,
    this.categoryNameFor,
    super.key,
  });

  final List<PropertyEntity> properties;
  final ValueChanged<PropertyEntity> onTap;

  /// Category display name for the location fallback (Q4).
  final String? Function(String slug)? categoryNameFor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.featuredCardHeight.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSizes.screenHorizontalPadding.w,
        ),
        itemCount: properties.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSizes.featuredCardGap.w),
        itemBuilder: (_, index) {
          final property = properties[index];
          return FeaturedPropertyCard(
            property: property,
            categoryName: categoryNameFor?.call(property.category),
            onTap: () => onTap(property),
          );
        },
      ),
    );
  }
}
