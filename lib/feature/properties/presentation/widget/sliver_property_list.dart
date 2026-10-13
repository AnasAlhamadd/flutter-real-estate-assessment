import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_card_skeletons.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_list_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Column of [PropertyListCard]s (`1:4170`), [AppSizes.listGap] apart, as in
/// the Explore list. Built lazily, so long result lists stay cheap.
class SliverPropertyList extends StatelessWidget {
  const SliverPropertyList({
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
    final gap = AppSizes.listGap.h;
    return SliverList.separated(
      itemCount: properties.length,
      separatorBuilder: (_, _) => SizedBox(height: gap),
      itemBuilder: (context, index) {
        final property = properties[index];
        return PropertyListCard(
          key: ValueKey(property.id),
          property: property,
          categoryName: categoryNameFor?.call(property.category),
          favoriteButton: favoriteButtonBuilder?.call(property),
          onTap: () => onTap(property),
        );
      },
    );
  }
}

/// [count] [PropertyListCardSkeleton]s spaced like [SliverPropertyList],
/// announced once as "Loading".
class SliverPropertyListSkeleton extends StatelessWidget {
  const SliverPropertyListSkeleton({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final gap = AppSizes.listGap.h;
    return SliverToBoxAdapter(
      child: Semantics(
        label: context.tr(AppTextKeys.commonLoading),
        excludeSemantics: true,
        child: Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(height: gap),
              const PropertyListCardSkeleton(),
            ],
          ],
        ),
      ),
    );
  }
}
