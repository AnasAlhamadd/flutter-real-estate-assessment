import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';

/// Filters chosen in the Filter sheet. Any active filter switches Explore to
/// the full matching set, filtered on the device (reference §4.5.1).
class PropertyFilter extends Equatable {
  const PropertyFilter({this.categorySlugs = const {}, this.priceRange});

  static const PropertyFilter none = PropertyFilter();

  /// Empty means every category.
  final Set<String> categorySlugs;

  /// `null` means no price filter. A side dragged to the end of the slider
  /// is open: `min` 0 or `max` infinity.
  final PriceRange? priceRange;

  bool get isActive => categorySlugs.isNotEmpty || priceRange != null;

  @override
  List<Object?> get props => [categorySlugs, priceRange];
}
