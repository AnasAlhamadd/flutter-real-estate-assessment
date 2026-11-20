import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/enums/data_source.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_state.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';

/// Home: Featured (top rated), category chips, and the paginated
/// recommendations for the selected category.
///
/// Recommendation requests share one counter: selecting a category or
/// refreshing makes every older response (first page or next page) stale, so
/// it can't overwrite newer results.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this._getFeaturedProperties,
    required this._getCategories,
    required this._getRecommendations,
    Stream<bool>? connectivityChanges,
  }) : super(const HomeState()) {
    _connectivity = connectivityChanges?.listen(_onConnectivityChanged);
  }

  /// Featured count (Q18, approved 2026-10-13).
  static const int featuredLimit = 5;

  final GetFeaturedPropertiesUseCase _getFeaturedProperties;
  final GetCategoriesUseCase _getCategories;
  final GetRecommendationsUseCase _getRecommendations;

  StreamSubscription<bool>? _connectivity;
  bool? _wasConnected;
  int _recommendationsRequest = 0;

  Future<void> load() async {
    await Future.wait([
      _loadFeatured(),
      _loadCategories(),
      _loadRecommendations(),
    ]);
  }

  Future<void> retryFeatured() => _loadFeatured();

  Future<void> retryRecommendations() async {
    await Future.wait([
      if (state.categoriesStatus == RequestStatus.failure) _loadCategories(),
      _loadRecommendations(),
    ]);
  }

  /// `null` selects "All". Selecting the current category does nothing.
  Future<void> selectCategory(String? slug) async {
    if (slug == state.selectedCategorySlug) return;
    emit(state.copyWith(selectedCategorySlug: () => slug));
    await _loadRecommendations();
  }

  /// Next recommendations page, when one exists and none is loading.
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

  /// The user's pull to refresh: sections with content show `loading`
  /// (skeletons) while their data stays in the state.
  Future<void> refresh() => _refresh(showLoading: true);

  @override
  Future<void> close() async {
    await _connectivity?.cancel();
    return super.close();
  }

  /// Sections that show content keep it when their request fails
  /// ([HomeState.refreshFailed]); sections without content load again.
  /// [showLoading] is false for refreshes the user didn't ask for.
  Future<void> _refresh({required bool showLoading}) async {
    if (state.isRefreshing) return;
    final hadFeatured = state.featuredStatus == RequestStatus.success;
    final hadRecommendations =
        state.recommendationsStatus == RequestStatus.success;
    emit(
      state.copyWith(
        isRefreshing: true,
        refreshFailed: false,
        featuredStatus: showLoading && hadFeatured
            ? RequestStatus.loading
            : null,
        recommendationsStatus: showLoading && hadRecommendations
            ? RequestStatus.loading
            : null,
      ),
    );
    final updated = await Future.wait([
      _refreshFeatured(hadContent: hadFeatured),
      _refreshCategories(),
      _refreshRecommendations(hadContent: hadRecommendations),
    ]);
    if (isClosed) return;
    emit(
      state.copyWith(
        isRefreshing: false,
        refreshFailed: updated.contains(false),
      ),
    );
  }

  /// Retries once when the device reconnects after being offline, and only
  /// if something is missing or stale.
  void _onConnectivityChanged(bool connected) {
    final restored = connected && _wasConnected == false;
    _wasConnected = connected;
    if (!restored || isClosed) return;
    if (state.featuredStatus == RequestStatus.failure ||
        state.recommendationsStatus == RequestStatus.failure ||
        state.recommendationsSource == DataSource.saved) {
      unawaited(_refresh(showLoading: false));
    } else if (state.loadMoreFailure != null) {
      unawaited(retryLoadMore());
    }
  }

  Future<void> _loadFeatured() async {
    emit(
      state.copyWith(
        featuredStatus: RequestStatus.loading,
        featuredFailure: () => null,
      ),
    );
    final result = await _getFeaturedProperties(
      const FeaturedParams(limit: featuredLimit),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          featuredStatus: RequestStatus.failure,
          featured: const [],
          featuredFailure: () => failure,
        ),
        (items) => state.copyWith(
          featuredStatus: items.isEmpty
              ? RequestStatus.empty
              : RequestStatus.success,
          featured: items,
        ),
      ),
    );
  }

  Future<void> _loadCategories() async {
    emit(state.copyWith(categoriesStatus: RequestStatus.loading));
    final result = await _getCategories(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (_) => state.copyWith(
          categoriesStatus: RequestStatus.failure,
          categories: const [],
        ),
        (categories) => state.copyWith(
          categoriesStatus: categories.isEmpty
              ? RequestStatus.empty
              : RequestStatus.success,
          categories: categories,
        ),
      ),
    );
  }

  Future<void> _loadRecommendations() async {
    final request = ++_recommendationsRequest;
    emit(
      state.copyWith(
        recommendationsStatus: RequestStatus.loading,
        recommendations: const [],
        recommendationsFailure: () => null,
        recommendationsPage: 0,
        hasReachedMax: false,
        isLoadingMore: false,
        loadMoreFailure: () => null,
        recommendationsSource: DataSource.remote,
      ),
    );
    final result = await _fetchPage(0);
    if (isClosed || request != _recommendationsRequest) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          recommendationsStatus: RequestStatus.failure,
          recommendationsFailure: () => failure,
        ),
        _withFirstPage,
      ),
    );
  }

  Future<void> _loadNextPage() async {
    final request = _recommendationsRequest;
    final nextPage = state.recommendationsPage + 1;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailure: () => null));
    final result = await _fetchPage(nextPage);
    if (isClosed || request != _recommendationsRequest) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          isLoadingMore: false,
          loadMoreFailure: () => failure,
        ),
        (page) {
          final known = {for (final item in state.recommendations) item.id};
          final added = page.items.where((item) => known.add(item.id));
          return state.copyWith(
            recommendations: List.unmodifiable([
              ...state.recommendations,
              ...added,
            ]),
            recommendationsPage: nextPage,
            hasReachedMax: page.hasReachedMax || page.items.isEmpty,
            isLoadingMore: false,
          );
        },
      ),
    );
  }

  Future<bool> _refreshFeatured({required bool hadContent}) async {
    if (!hadContent) {
      await _loadFeatured();
      return true;
    }
    final result = await _getFeaturedProperties(
      const FeaturedParams(limit: featuredLimit),
    );
    if (isClosed) return true;
    return result.fold(
      (_) {
        emit(state.copyWith(featuredStatus: RequestStatus.success));
        return false;
      },
      (items) {
        emit(
          state.copyWith(
            featuredStatus: items.isEmpty
                ? RequestStatus.empty
                : RequestStatus.success,
            featured: items,
          ),
        );
        return true;
      },
    );
  }

  /// Chips are secondary: a failed refresh keeps the current ones silently.
  Future<bool> _refreshCategories() async {
    if (state.categoriesStatus != RequestStatus.success) {
      await _loadCategories();
      return true;
    }
    final result = await _getCategories(const NoParams());
    if (isClosed) return true;
    result.fold((_) {}, (categories) {
      if (categories.isNotEmpty) emit(state.copyWith(categories: categories));
    });
    return true;
  }

  Future<bool> _refreshRecommendations({required bool hadContent}) async {
    if (!hadContent) {
      await _loadRecommendations();
      return true;
    }
    final request = ++_recommendationsRequest;
    final result = await _fetchPage(0);
    if (isClosed || request != _recommendationsRequest) return true;
    final page = result.toOption().toNullable();
    // A saved copy means the remote request failed: keep what is shown.
    if (page == null || page.isFromCache) {
      emit(
        state.copyWith(
          recommendationsStatus: RequestStatus.success,
          isLoadingMore: false,
        ),
      );
      return false;
    }
    emit(_withFirstPage(page));
    return true;
  }

  HomeState _withFirstPage(PropertiesPageEntity page) => state.copyWith(
    recommendationsStatus: page.items.isEmpty
        ? RequestStatus.empty
        : RequestStatus.success,
    recommendations: page.items,
    recommendationsFailure: () => null,
    recommendationsPage: 0,
    hasReachedMax: page.hasReachedMax,
    isLoadingMore: false,
    loadMoreFailure: () => null,
    recommendationsSource: page.isFromCache
        ? DataSource.saved
        : DataSource.remote,
  );

  Future<Either<Failure, PropertiesPageEntity>> _fetchPage(int page) =>
      _getRecommendations(
        RecommendationsParams(
          categorySlug: state.selectedCategorySlug,
          page: page,
        ),
      );
}
