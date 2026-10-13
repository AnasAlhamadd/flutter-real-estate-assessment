import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// What the result list shows.
enum SearchMode {
  /// The query is shorter than `SearchQuery.minLength`: the paged "All"
  /// listing, the same pages as Home.
  browse,

  /// Results for [SearchState.query].
  search,
}

/// One listing at a time (browse or one query). [status] describes its first
/// load only; work on visible results has its own flags ([isLoadingMore],
/// [isRefreshing]), so results are never replaced by a loading state.
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
    this.isFromCache = false,
    this.categories = const [],
  });

  final SearchMode mode;

  /// Normalized query of the shown results; empty in browse mode.
  final String query;
  final RequestStatus status;

  /// Every loaded page, unique ids.
  final List<PropertyEntity> items;

  /// Matches reported by the API.
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

  /// Browse only: the persisted "All" first page, shown after a remote
  /// failure. Pagination waits for a successful refresh.
  final bool isFromCache;

  /// For the card location fallback (brand → category name → slug).
  final List<CategoryEntity> categories;

  bool get canLoadMore =>
      status == RequestStatus.success &&
      !hasReachedMax &&
      !isLoadingMore &&
      loadMoreFailure == null &&
      !isRefreshing &&
      !isFromCache;

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
    bool? isFromCache,
    List<CategoryEntity>? categories,
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
    isFromCache: isFromCache ?? this.isFromCache,
    categories: categories ?? this.categories,
  );

  /// A first load of [mode]/[query] with nothing shown yet. Categories stay.
  SearchState loading({required SearchMode mode, String query = ''}) =>
      SearchState(
        mode: mode,
        query: query,
        status: RequestStatus.loading,
        categories: categories,
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
    isFromCache,
    categories,
  ];
}
