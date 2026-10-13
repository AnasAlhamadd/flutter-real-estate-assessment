import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class PropertiesPageEntity extends Equatable {
  const PropertiesPageEntity({
    required this.items,
    required this.total,
    required this.hasReachedMax,
    this.isFromCache = false,
    this.cachedAt,
  });

  final List<PropertyEntity> items;

  /// Number of matches reported by the API, used for "Found {n}" in paged mode.
  final int total;
  final bool hasReachedMax;

  /// True when served from the persisted first page after a remote failure.
  final bool isFromCache;
  final DateTime? cachedAt;

  @override
  List<Object?> get props => [
    items,
    total,
    hasReachedMax,
    isFromCache,
    cachedAt,
  ];
}
