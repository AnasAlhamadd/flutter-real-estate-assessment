import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_card_skeletons.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Grid of [PropertyGridCard]s (Figma "Our Recommendation" rows `1:4472`).
///
/// Built as rows instead of a `SliverGrid`, because a grid needs a fixed
/// item height and the card height grows with the user's text scale. The
/// column count follows the available width: two on phones (as in Figma),
/// more on wide screens so cards don't stretch.
class SliverPropertyGrid extends StatelessWidget {
  const SliverPropertyGrid({
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

  /// Columns that fit [width] with cards at least
  /// [AppSizes.gridCardMinWidth] wide, clamped to the design's range.
  static int columnsFor(double width, {required double gap}) {
    final fitting = ((width + gap) / (AppSizes.gridCardMinWidth + gap)).floor();
    return math.max(
      AppSizes.gridMinColumns,
      math.min(AppSizes.gridMaxColumns, fitting),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SliverGridRows(
      itemCount: (_) => properties.length,
      cellBuilder: (index) {
        final property = properties[index];
        return PropertyGridCard(
          property: property,
          categoryName: categoryNameFor?.call(property.category),
          onTap: () => onTap(property),
          favoriteButton: favoriteButtonBuilder?.call(property),
        );
      },
    );
  }
}

/// [rows] full rows of [PropertyGridCardSkeleton]s in the same columns as
/// [SliverPropertyGrid], announced once as "Loading".
class SliverPropertyGridSkeleton extends StatelessWidget {
  const SliverPropertyGridSkeleton({this.rows = 2, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return SliverSemantics(
      label: context.tr(AppTextKeys.commonLoading),
      excludeSemantics: true,
      sliver: _SliverGridRows(
        itemCount: (columns) => rows * columns,
        cellBuilder: (_) => const PropertyGridCardSkeleton(),
      ),
    );
  }
}

class _SliverGridRows extends StatelessWidget {
  const _SliverGridRows({required this.itemCount, required this.cellBuilder});

  final int Function(int columns) itemCount;
  final Widget Function(int index) cellBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSizes.gridHorizontalGap.w;
        final columns = SliverPropertyGrid.columnsFor(
          constraints.crossAxisExtent,
          gap: gap,
        );
        final count = itemCount(columns);
        return SliverList.separated(
          itemCount: (count / columns).ceil(),
          separatorBuilder: (_, _) =>
              SizedBox(height: AppSizes.gridVerticalGap.h),
          itemBuilder: (_, row) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var column = 0; column < columns; column++) ...[
                if (column > 0) SizedBox(width: gap),
                Expanded(child: _cell(row * columns + column, count)),
              ],
            ],
          ),
        );
      },
    );
  }

  /// An empty cell keeps the last, incomplete row aligned to the columns.
  Widget _cell(int index, int count) =>
      index < count ? cellBuilder(index) : const SizedBox.shrink();
}
