import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Applies the category and price filters to an already loaded full set.
///
/// Synchronous and pure (no repository), because DummyJSON can't combine
/// search with category, filter by several categories or filter by price.
class FilterPropertiesUseCase {
  const FilterPropertiesUseCase();

  List<PropertyEntity> call(FilterParams params) => params.items
      .where(
        (item) =>
            (params.categorySlugs.isEmpty ||
                params.categorySlugs.contains(item.category)) &&
            (params.priceRange?.contains(item.price) ?? true),
      )
      .toList(growable: false);
}

class FilterParams extends Equatable {
  const FilterParams({
    required this.items,
    this.categorySlugs = const {},
    this.priceRange,
  });

  final List<PropertyEntity> items;

  /// Empty means every category.
  final Set<String> categorySlugs;

  /// `null` means no price filter.
  final PriceRange? priceRange;

  @override
  List<Object?> get props => [items, categorySlugs, priceRange];
}
