import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/enums/data_source.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';

/// What the result list shows.
enum SearchMode {
  /// The query is shorter than `SearchQuery.minLength`: the paged "All"
  /// listing, the same pages as Home.
  browse,

  /// Results for [SearchState.query].
  search,

  /// [SearchState.filter] applied on the device to the full matching set of
  /// [SearchState.query] (the whole catalog when it is empty).
  filtered,
}

/// One listing at a time (browse or one query). [status] is `loading` during
/// the first load and during the user's pull to refresh; the refresh keeps
/// [items] in the state, so a failure goes back to the previous status with
/// the same results ([refreshFailed]). Background refreshes and next pages
/// keep the status ([isRefreshing], [isLoadingMore]).
class SearchState extends Equatable {
  const SearchState({
    this.mode = SearchMode.browse,
    this.query = '',
    this.status = RequestStatus.initial,
    this.items = const [],
    this.total = 0,
    this.hasReachedMax = false,
    this.failure,
    this.browsePage = 0,
    this.isLoadingMore = false,
    this.loadMoreFailure,
    this.isRefreshing = false,
    this.refreshFailed = false,
    this.source = DataSource.remote,
    this.categories = const [],
    this.filter = PropertyFilter.none,
  });

  final SearchMode mode;

  /// Normalized query of the shown results; empty in browse mode, and in
  /// filtered mode without search text.
  final String query;
  final RequestStatus status;

  /// Every loaded page, unique ids.
  final List<PropertyEntity> items;

  /// Matches reported by the API; in filtered mode, the filtered count.
  final int total;
  final bool hasReachedMax;

  /// The first load failed and nothing is shown.
  final Failure? failure;

  /// Index of the last loaded browse page (search pages are tracked by the
  /// repository's cache).
  final int browsePage;
  final bool isLoadingMore;

  /// The next page failed; loaded items stay and a retry is offered.
  final Failure? loadMoreFailure;

  /// Pull to refresh, or a background refresh of stale cached results.
  final bool isRefreshing;

  /// The last refresh couldn't update the results already shown.
  final bool refreshFailed;

  /// [DataSource.saved] in browse mode only: the persisted "All" first page,
  /// shown after a remote failure.
  final DataSource source;

  /// For the card location fallback (brand → category name → slug).
  final List<CategoryEntity> categories;

  /// The applied Filter sheet choices; kept across queries.
  final PropertyFilter filter;

  bool get canLoadMore =>
      status == RequestStatus.success &&
      !hasReachedMax &&
      !isLoadingMore &&
      loadMoreFailure == null &&
      !isRefreshing &&
      source == DataSource.remote;

  String? categoryNameFor(String slug) {
    for (final category in categories) {
      if (category.slug == slug) return category.name;
    }
    return null;
  }

  SearchState copyWith({
    SearchMode? mode,
    String? query,
    RequestStatus? status,
    List<PropertyEntity>? items,
    int? total,
    bool? hasReachedMax,
    ValueGetter<Failure?>? failure,
    int? browsePage,
    bool? isLoadingMore,
    ValueGetter<Failure?>? loadMoreFailure,
    bool? isRefreshing,
    bool? refreshFailed,
    DataSource? source,
    List<CategoryEntity>? categories,
    PropertyFilter? filter,
  }) => SearchState(
    mode: mode ?? this.mode,
    query: query ?? this.query,
    status: status ?? this.status,
    items: items ?? this.items,
    total: total ?? this.total,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    failure: failure != null ? failure() : this.failure,
    browsePage: browsePage ?? this.browsePage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailure: loadMoreFailure != null
        ? loadMoreFailure()
        : this.loadMoreFailure,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    refreshFailed: refreshFailed ?? this.refreshFailed,
    source: source ?? this.source,
    categories: categories ?? this.categories,
    filter: filter ?? this.filter,
  );

  /// A first load of [mode]/[query] with nothing shown yet. Categories and
  /// the filter stay.
  SearchState loading({required SearchMode mode, String query = ''}) =>
      SearchState(
        mode: mode,
        query: query,
        status: RequestStatus.loading,
        categories: categories,
        filter: filter,
      );

  @override
  List<Object?> get props => [
    mode,
    query,
    status,
    items,
    total,
    hasReachedMax,
    failure,
    browsePage,
    isLoadingMore,
    loadMoreFailure,
    isRefreshing,
    refreshFailed,
    source,
    categories,
    filter,
  ];
}
