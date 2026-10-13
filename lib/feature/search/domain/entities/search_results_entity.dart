import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Every page loaded so far for one normalized search query.
class SearchResultsEntity extends Equatable {
  const SearchResultsEntity({
    required this.query,
    required this.items,
    required this.total,
    required this.hasReachedMax,
    this.isStale = false,
  });

  final String query;

  /// Loaded pages in API order, unique ids.
  final List<PropertyEntity> items;

  /// Matches reported by the API, used for "Found {n}".
  final int total;
  final bool hasReachedMax;

  /// Served from the session cache after its freshness window: still shown,
  /// and worth refreshing in the background.
  final bool isStale;

  @override
  List<Object?> get props => [query, items, total, hasReachedMax, isStale];
}
