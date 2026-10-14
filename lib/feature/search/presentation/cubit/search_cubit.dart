import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/filter_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/search_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_query.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/get_cached_search_results_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/load_more_search_results_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/refresh_search_results_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/search_first_page_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/search_page_params.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_state.dart';

/// Explore: the paged "All" listing until the query has
/// [SearchQuery.minLength] characters, then debounced, cached, paged search.
/// While a [PropertyFilter] is active, the full matching set of the query
/// (or the whole catalog) is loaded once and filtered on the device, because
/// the API can't combine search, several categories and a price range
/// (reference §4.5.1).
///
/// Every request captures [_generation]; a new query, a mode switch or a
/// refresh bumps it, so a late response (first page, next page or refresh)
/// can never change the results of a newer listing. Superseded search
/// requests are also cancelled through their [CancellationSignal].
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required this._getCachedResults,
    required this._searchFirstPage,
    required this._loadMoreResults,
    required this._refreshResults,
    required this._getBrowsePage,
    required this._getCategories,
    required this._getAllMatches,
    this._filterProperties = const FilterPropertiesUseCase(),
    this.debounce = defaultDebounce,
    Stream<bool>? connectivityChanges,
  }) : super(const SearchState()) {
    _connectivity = connectivityChanges?.listen(_onConnectivityChanged);
  }

  static const Duration defaultDebounce = Duration(milliseconds: 300);

  final GetCachedSearchResultsUseCase _getCachedResults;
  final SearchFirstPageUseCase _searchFirstPage;
  final LoadMoreSearchResultsUseCase _loadMoreResults;
  final RefreshSearchResultsUseCase _refreshResults;
  final GetRecommendationsUseCase _getBrowsePage;
  final GetCategoriesUseCase _getCategories;
  final SearchPropertiesUseCase _getAllMatches;
  final FilterPropertiesUseCase _filterProperties;

  /// Pause after the last keystroke before a search starts.
  final Duration debounce;

  StreamSubscription<bool>? _connectivity;
  bool? _wasConnected;
  Timer? _debounceTimer;
  CancellationSignal? _cancellation;
  int _generation = 0;

  /// Normalized query of the latest scheduled or shown search; empty for
  /// browse. Repeated text (e.g. an added trailing space) is ignored.
  String _requestedQuery = '';

  /// The browse listing as it was when a search replaced it.
  SearchState? _browseSnapshot;

  /// The latest searchable query, including one still waiting for the
  /// debounce; empty when the text is too short. The Filter sheet describes
  /// this scope.
  String get requestedQuery => _requestedQuery;

  Future<void> load() async {
    await Future.wait([_loadCategories(), _loadBrowse()]);
  }

  /// Text field changes. Short queries switch to browse (or the filtered
  /// catalog) at once; others search after [debounce].
  void onQueryChanged(String text) {
    final query = _searchQueryOf(text);
    if (query == _requestedQuery) return;
    _requestedQuery = query;
    _invalidate();
    if (query.isEmpty) {
      unawaited(_showWithoutQuery());
      return;
    }
    _debounceTimer = Timer(debounce, () => unawaited(_runQuery(query)));
  }

  /// Keyboard search action: runs a pending search without waiting.
  Future<void> submitQuery(String text) async {
    onQueryChanged(text);
    final timer = _debounceTimer;
    if (timer == null || !timer.isActive) return;
    timer.cancel();
    await _runQuery(_requestedQuery);
  }

  /// Filter sheet "Set Filter". An unchanged filter sends nothing; an empty
  /// one returns to the paged listing of the current query.
  Future<void> applyFilter(PropertyFilter filter) async {
    if (filter == state.filter) return;
    _invalidate();
    emit(state.copyWith(filter: filter));
    if (_requestedQuery.isEmpty) return _showWithoutQuery();
    await _runQuery(_requestedQuery);
  }

  /// Next page, when one exists and nothing else is loading.
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    await _loadNextPage();
  }

  Future<void> retryLoadMore() async {
    if (state.loadMoreFailure == null ||
        state.isLoadingMore ||
        state.isRefreshing) {
      return;
    }
    await _loadNextPage();
  }

  /// Retries a failed first load.
  Future<void> retry() async {
    if (state.status != RequestStatus.failure) return;
    return switch (state.mode) {
      SearchMode.browse => _loadBrowse(),
      SearchMode.search => _search(state.query),
      SearchMode.filtered => _loadFiltered(state.query),
    };
  }

  /// Pull to refresh. Shown results stay when the refresh fails
  /// ([SearchState.refreshFailed]); a failed first load is retried.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    if (!_hasResultsState(state)) return retry();
    await _refreshShown();
  }

  @override
  Future<void> close() async {
    _invalidate();
    await _connectivity?.cancel();
    return super.close();
  }

  static String _searchQueryOf(String text) {
    final query = SearchQuery.normalize(text);
    return SearchQuery.isSearchable(query) ? query : '';
  }

  static bool _hasResultsState(SearchState state) =>
      state.status == RequestStatus.success ||
      state.status == RequestStatus.empty;

  bool _isOutdated(int generation) => isClosed || generation != _generation;

  /// Drops pending work for the current listing.
  void _invalidate() {
    _debounceTimer?.cancel();
    _cancellation?.cancel();
    _generation++;
  }

  void _onConnectivityChanged(bool connected) {
    final restored = connected && _wasConnected == false;
    _wasConnected = connected;
    if (!restored || isClosed) return;
    if (state.status == RequestStatus.failure) {
      unawaited(retry());
    } else if (state.isFromCache) {
      unawaited(refresh());
    } else if (state.loadMoreFailure != null) {
      unawaited(retryLoadMore());
    }
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories(const NoParams());
    if (isClosed) return;
    result.fold((_) {}, (categories) {
      emit(state.copyWith(categories: categories));
    });
  }

  Future<void> _runQuery(String query) =>
      state.filter.isActive ? _loadFiltered(query) : _search(query);

  Future<void> _showWithoutQuery() =>
      state.filter.isActive ? _loadFiltered('') : _showBrowse();

  Future<void> _showBrowse() async {
    final snapshot = _browseSnapshot;
    if (snapshot == null) return _loadBrowse();
    emit(
      snapshot.copyWith(
        categories: state.categories,
        filter: state.filter,
        isLoadingMore: false,
        isRefreshing: false,
        refreshFailed: false,
      ),
    );
  }

  /// Keeps the shown browse listing, so leaving search or filters restores
  /// it without a request.
  void _rememberBrowse() {
    if (state.mode != SearchMode.browse) return;
    _browseSnapshot = _hasResultsState(state) ? state : null;
  }

  Future<void> _loadBrowse() async {
    final generation = ++_generation;
    emit(state.loading(mode: SearchMode.browse));
    final result = await _getBrowsePage(const RecommendationsParams(page: 0));
    if (_isOutdated(generation)) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: RequestStatus.failure,
          failure: () => failure,
        ),
        _withFirstBrowsePage,
      ),
    );
  }

  Future<void> _search(String query) async {
    _debounceTimer?.cancel();
    _cancellation?.cancel();
    final cancellation = _cancellation = CancellationSignal();
    final generation = ++_generation;
    _rememberBrowse();
    final base = state.loading(mode: SearchMode.search, query: query);
    final cached = _getCachedResults(query);
    if (cached != null) {
      emit(_withResults(base, cached));
      if (cached.isStale) unawaited(_refreshShown());
      return;
    }
    emit(base);
    final result = await _searchFirstPage(
      SearchPageParams(query: query, cancellation: cancellation),
    );
    if (_isOutdated(generation)) return;
    result.fold((failure) {
      if (failure is CancelledFailure) return;
      emit(
        state.copyWith(status: RequestStatus.failure, failure: () => failure),
      );
    }, (results) => emit(_withResults(state, results)));
  }

  /// The full set comes from the repository's memory copy when it is fresh
  /// (e.g. loaded by the Filter sheet), so applying or changing filters
  /// usually sends no request.
  Future<void> _loadFiltered(String query) async {
    _debounceTimer?.cancel();
    _cancellation?.cancel();
    final cancellation = _cancellation = CancellationSignal();
    final generation = ++_generation;
    _rememberBrowse();
    emit(state.loading(mode: SearchMode.filtered, query: query));
    final result = await _getAllMatches(
      SearchParams(query: query, cancellation: cancellation),
    );
    if (_isOutdated(generation)) return;
    result.fold((failure) {
      if (failure is CancelledFailure) return;
      emit(
        state.copyWith(status: RequestStatus.failure, failure: () => failure),
      );
    }, (page) => emit(_withFiltered(state, page.items)));
  }

  Future<void> _loadNextPage() async {
    final generation = _generation;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailure: () => null));
    if (state.mode == SearchMode.browse) {
      return _loadNextBrowsePage(generation);
    }
    final result = await _loadMoreResults(
      SearchPageParams(query: state.query, cancellation: _cancellation),
    );
    if (_isOutdated(generation)) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          isLoadingMore: false,
          loadMoreFailure: () => failure is CancelledFailure ? null : failure,
        ),
        (results) => _withResults(state, results),
      ),
    );
  }

  Future<void> _loadNextBrowsePage(int generation) async {
    final nextPage = state.browsePage + 1;
    final result = await _getBrowsePage(RecommendationsParams(page: nextPage));
    if (_isOutdated(generation)) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          isLoadingMore: false,
          loadMoreFailure: () => failure,
        ),
        (page) {
          final known = {for (final item in state.items) item.id};
          final added = page.items.where((item) => known.add(item.id));
          return state.copyWith(
            items: List.unmodifiable([...state.items, ...added]),
            total: page.total,
            browsePage: nextPage,
            hasReachedMax: page.hasReachedMax || page.items.isEmpty,
            isLoadingMore: false,
          );
        },
      ),
    );
  }

  Future<void> _refreshShown() async {
    final generation = ++_generation;
    emit(state.copyWith(isRefreshing: true, refreshFailed: false));
    final SearchState? updated = switch (state.mode) {
      SearchMode.browse => await _refreshedBrowse(),
      SearchMode.search => await _refreshedSearch(),
      SearchMode.filtered => await _refreshedFiltered(),
    };
    if (_isOutdated(generation)) return;
    emit(
      (updated ?? state.copyWith(refreshFailed: true)).copyWith(
        isRefreshing: false,
        isLoadingMore: false,
      ),
    );
  }

  /// `null` when the refresh failed. A saved copy counts as a failure: the
  /// remote request didn't succeed.
  Future<SearchState?> _refreshedBrowse() async {
    final result = await _getBrowsePage(const RecommendationsParams(page: 0));
    final page = result.toOption().toNullable();
    if (page == null || page.isFromCache) return null;
    return _withFirstBrowsePage(page);
  }

  Future<SearchState?> _refreshedSearch() async {
    final result = await _refreshResults(
      SearchPageParams(query: state.query, cancellation: _cancellation),
    );
    return result.fold(
      // A cancelled refresh belongs to a query that is no longer shown.
      (failure) => failure is CancelledFailure ? state : null,
      (results) => _withResults(state, results),
    );
  }

  Future<SearchState?> _refreshedFiltered() async {
    final result = await _getAllMatches(
      SearchParams(
        query: state.query,
        cancellation: _cancellation,
        forceRefresh: true,
      ),
    );
    return result.fold(
      (failure) => failure is CancelledFailure ? state : null,
      (page) => _withFiltered(state, page.items),
    );
  }

  /// [base] with [all] narrowed by its filter. Everything is shown at once,
  /// so there is no next page.
  SearchState _withFiltered(SearchState base, List<PropertyEntity> all) {
    final filter = base.filter;
    final items = _filterProperties(
      FilterParams(
        items: all,
        categorySlugs: filter.categorySlugs,
        priceRange: filter.priceRange,
      ),
    );
    return base.copyWith(
      mode: SearchMode.filtered,
      status: items.isEmpty ? RequestStatus.empty : RequestStatus.success,
      items: items,
      total: items.length,
      hasReachedMax: true,
      failure: () => null,
      isLoadingMore: false,
      loadMoreFailure: () => null,
      isFromCache: false,
    );
  }

  SearchState _withFirstBrowsePage(PropertiesPageEntity page) => state.copyWith(
    mode: SearchMode.browse,
    query: '',
    status: page.items.isEmpty ? RequestStatus.empty : RequestStatus.success,
    items: page.items,
    total: page.total,
    hasReachedMax: page.hasReachedMax,
    failure: () => null,
    browsePage: 0,
    isLoadingMore: false,
    loadMoreFailure: () => null,
    isFromCache: page.isFromCache,
  );

  static SearchState _withResults(
    SearchState base,
    SearchResultsEntity results,
  ) => base.copyWith(
    mode: SearchMode.search,
    query: results.query,
    status: results.items.isEmpty ? RequestStatus.empty : RequestStatus.success,
    items: results.items,
    total: results.total,
    hasReachedMax: results.hasReachedMax,
    failure: () => null,
    isLoadingMore: false,
    loadMoreFailure: () => null,
    isFromCache: false,
  );
}
