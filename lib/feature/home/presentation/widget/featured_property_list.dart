import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_card_skeletons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal row of Featured cards (Figma `1:4469`). It starts from the
/// reading side, so Arabic scrolls from the right.
class FeaturedPropertyList extends StatelessWidget {
  const FeaturedPropertyList({
    required this.properties,
    required this.onTap,
    this.categoryNameFor,
    this.favoriteButtonBuilder,
    super.key,
  });

  final List<PropertyEntity> properties;
  final ValueChanged<PropertyEntity> onTap;

  /// Category display name for the location fallback (Q4).
  final String? Function(String slug)? categoryNameFor;

  /// Heart for each card; none when `null`.
  final Widget Function(PropertyEntity property)? favoriteButtonBuilder;

  @override
  Widget build(BuildContext context) {
    return _FeaturedRow(
      itemCount: properties.length,
      itemBuilder: (index) {
        final property = properties[index];
        return FeaturedPropertyCard(
          property: property,
          categoryName: categoryNameFor?.call(property.category),
          onTap: () => onTap(property),
          favoriteButton: favoriteButtonBuilder?.call(property),
        );
      },
    );
  }
}

/// Featured row while loading: card-shaped skeletons, announced once as
/// "Loading". Not scrollable.
class FeaturedPropertyListSkeleton extends StatelessWidget {
  const FeaturedPropertyListSkeleton({super.key});

  /// More than fit on a phone, so wide screens aren't half empty.
  static const int count = 4;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr(AppTextKeys.commonLoading),
      child: ExcludeSemantics(
        child: _FeaturedRow(
          itemCount: count,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_) => const FeaturedPropertyCardSkeleton(),
        ),
      ),
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
  });

  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.featuredCardHeight.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: physics,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSizes.screenHorizontalPadding.w,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(width: AppSizes.featuredCardGap.w),
        itemBuilder: (_, index) => itemBuilder(index),
      ),
    );
  }
}
