import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/widget/appear_animation.dart';
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
///
/// Each card plays [AppearAnimation] the first time it is built, one column
/// after another, so a new page arrives row by row. Cards rebuilt after
/// scrolling back don't replay it; a replaced list (new category, refresh)
/// does.
class SliverPropertyGrid extends StatefulWidget {
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

  /// Delay between neighbouring columns of one row.
  static const Duration columnStagger = Duration(milliseconds: 70);

  @override
  State<SliverPropertyGrid> createState() => _SliverPropertyGridState();
}

class _SliverPropertyGridState extends State<SliverPropertyGrid> {
  final Set<int> _appeared = {};

  /// Part of each card's key, so a replaced list builds new cards even where
  /// the same id sits in the same place.
  int _generation = 0;

  @override
  void didUpdateWidget(SliverPropertyGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_extends(oldWidget.properties, widget.properties)) return;
    _appeared.clear();
    _generation++;
  }

  /// Whether [next] is [previous] with more items appended (a new page).
  static bool _extends(
    List<PropertyEntity> previous,
    List<PropertyEntity> next,
  ) {
    if (next.length < previous.length) return false;
    for (var i = 0; i < previous.length; i++) {
      if (previous[i].id != next[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _SliverGridRows(
      itemCount: (_) => widget.properties.length,
      cellBuilder: (index, column) {
        final property = widget.properties[index];
        return AppearAnimation(
          key: ValueKey((_generation, property.id)),
          animate: _appeared.add(property.id),
          delay: SliverPropertyGrid.columnStagger * column,
          child: PropertyGridCard(
            property: property,
            categoryName: widget.categoryNameFor?.call(property.category),
            onTap: () => widget.onTap(property),
            favoriteButton: widget.favoriteButtonBuilder?.call(property),
          ),
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
        cellBuilder: (_, _) => const PropertyGridCardSkeleton(),
      ),
    );
  }
}

class _SliverGridRows extends StatelessWidget {
  const _SliverGridRows({required this.itemCount, required this.cellBuilder});

  final int Function(int columns) itemCount;

  /// Builds the item at [index], shown in [column] (0 at the reading start).
  final Widget Function(int index, int column) cellBuilder;

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
                Expanded(child: _cell(row * columns + column, column, count)),
              ],
            ],
          ),
        );
      },
    );
  }

  /// An empty cell keeps the last, incomplete row aligned to the columns.
  Widget _cell(int index, int column, int count) =>
      index < count ? cellBuilder(index, column) : const SizedBox.shrink();
}
