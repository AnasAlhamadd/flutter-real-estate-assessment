import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Loaded pages of one query, plus where the next page starts.
class SearchCacheEntry extends Equatable {
  const SearchCacheEntry({
    required this.items,
    required this.total,
    required this.nextSkip,
    required this.hasReachedMax,
    required this.fetchedAt,
  });

  /// API order, unique ids.
  final List<PropertyEntity> items;
  final int total;

  /// API offset of the next page: the sum of the returned page sizes, which
  /// can exceed [items].length when a page repeated an id.
  final int nextSkip;
  final bool hasReachedMax;

  /// When the first page of this entry was fetched or last refreshed.
  final DateTime fetchedAt;

  @override
  List<Object?> get props => [items, total, nextSkip, hasReachedMax, fetchedAt];
}

/// Session cache of search results, keyed by normalized query. Memory only
/// (persisting search results is outside the approved storage scope, §4.5.2),
/// so it is empty after every launch.
///
/// Bounded: at most [maxQueries] queries, least recently used first out.
/// Each entry is bounded by the API's match count.
abstract interface class SearchResultsLocalDataSource {
  SearchCacheEntry? read(String query);

  void write(String query, SearchCacheEntry entry);

  /// Whether [entry] is older than the freshness window at [now]. Stale
  /// entries are still served; callers refresh them in the background.
  bool isStale(SearchCacheEntry entry, DateTime now);
}

class SearchResultsMemoryDataSource implements SearchResultsLocalDataSource {
  SearchResultsMemoryDataSource({
    this.maxQueries = defaultMaxQueries,
    this.freshFor = defaultFreshFor,
  }) : assert(maxQueries > 0);

  static const int defaultMaxQueries = 20;
  static const Duration defaultFreshFor = Duration(minutes: 10);

  final int maxQueries;
  final Duration freshFor;

  /// Insertion-ordered: the first key is the least recently used.
  final LinkedHashMap<String, SearchCacheEntry> _entries = LinkedHashMap();

  @override
  SearchCacheEntry? read(String query) {
    final entry = _entries.remove(query);
    if (entry != null) _entries[query] = entry;
    return entry;
  }

  @override
  void write(String query, SearchCacheEntry entry) {
    _entries
      ..remove(query)
      ..[query] = entry;
    while (_entries.length > maxQueries) {
      _entries.remove(_entries.keys.first);
    }
  }

  @override
  bool isStale(SearchCacheEntry entry, DateTime now) =>
      now.difference(entry.fetchedAt) > freshFor;
}
