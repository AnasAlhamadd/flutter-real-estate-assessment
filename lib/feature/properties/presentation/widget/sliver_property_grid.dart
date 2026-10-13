import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
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
    super.key,
  });

  final List<PropertyEntity> properties;
  final ValueChanged<PropertyEntity> onTap;

  /// Category display name for the location fallback (Q4).
  final String? Function(String slug)? categoryNameFor;

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
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSizes.gridHorizontalGap.w;
        final columns = columnsFor(constraints.crossAxisExtent, gap: gap);
        final rowCount = (properties.length / columns).ceil();
        return SliverList.separated(
          itemCount: rowCount,
          separatorBuilder: (_, _) =>
              SizedBox(height: AppSizes.gridVerticalGap.h),
          itemBuilder: (_, row) => _buildRow(row, columns, gap),
        );
      },
    );
  }

  Widget _buildRow(int row, int columns, double gap) {
    final start = row * columns;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var column = 0; column < columns; column++) ...[
          if (column > 0) SizedBox(width: gap),
          Expanded(child: _buildCell(start + column)),
        ],
      ],
    );
  }

  /// An empty cell keeps the last, incomplete row aligned to the columns.
  Widget _buildCell(int index) {
    if (index >= properties.length) return const SizedBox.shrink();
    final property = properties[index];
    return PropertyGridCard(
      property: property,
      categoryName: categoryNameFor?.call(property.category),
      onTap: () => onTap(property),
    );
  }
}
