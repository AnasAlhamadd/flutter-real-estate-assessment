import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/price_histogram.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';

/// The Filter sheet's draft. Nothing reaches Explore until "Set Filter".
class FilterState extends Equatable {
  const FilterState({
    this.priceStatus = RequestStatus.initial,
    this.histogram,
    this.failure,
    this.categories = const [],
    this.selectedCategories = const {},
    this.initialPriceRange,
    this.rangeStart = 0,
    this.rangeEnd = 1,
  });

  /// Loading of the full matching set behind [histogram].
  final RequestStatus priceStatus;
  final PriceHistogram? histogram;
  final Failure? failure;

  /// API categories; the "Property Type" section is hidden while empty.
  final List<CategoryEntity> categories;
  final Set<String> selectedCategories;

  /// The applied price filter, kept as is until [histogram] is known.
  final PriceRange? initialPriceRange;

  /// Slider positions on [histogram]'s scale (0–1).
  final double rangeStart;
  final double rangeEnd;

  PriceRange? get priceRange {
    final histogram = this.histogram;
    if (histogram == null) return initialPriceRange;
    return histogram.rangeFor(rangeStart, rangeEnd);
  }

  PropertyFilter get filter =>
      PropertyFilter(categorySlugs: selectedCategories, priceRange: priceRange);

  FilterState copyWith({
    RequestStatus? priceStatus,
    ValueGetter<PriceHistogram?>? histogram,
    ValueGetter<Failure?>? failure,
    List<CategoryEntity>? categories,
    Set<String>? selectedCategories,
    ValueGetter<PriceRange?>? initialPriceRange,
    double? rangeStart,
    double? rangeEnd,
  }) => FilterState(
    priceStatus: priceStatus ?? this.priceStatus,
    histogram: histogram != null ? histogram() : this.histogram,
    failure: failure != null ? failure() : this.failure,
    categories: categories ?? this.categories,
    selectedCategories: selectedCategories ?? this.selectedCategories,
    initialPriceRange: initialPriceRange != null
        ? initialPriceRange()
        : this.initialPriceRange,
    rangeStart: rangeStart ?? this.rangeStart,
    rangeEnd: rangeEnd ?? this.rangeEnd,
  );

  @override
  List<Object?> get props => [
    priceStatus,
    histogram,
    failure,
    categories,
    selectedCategories,
    initialPriceRange,
    rangeStart,
    rangeEnd,
  ];
}
