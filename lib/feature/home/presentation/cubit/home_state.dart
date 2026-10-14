import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/enums/data_source.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Home has three independent sections, so a failure in one never hides the
/// others: Featured, the category chips, and the recommendation grid.
///
/// A section's status is `loading` during its first load and during the
/// user's pull to refresh; the refresh keeps the loaded data in the state, so
/// a failure goes back to `success` with the same items ([refreshFailed]).
/// Background refreshes (reconnect) keep the status as it is.
class HomeState extends Equatable {
  const HomeState({
    this.featuredStatus = RequestStatus.initial,
    this.featured = const [],
    this.featuredFailure,
    this.categoriesStatus = RequestStatus.initial,
    this.categories = const [],
    this.selectedCategorySlug,
    this.recommendationsStatus = RequestStatus.initial,
    this.recommendations = const [],
    this.recommendationsFailure,
    this.recommendationsPage = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.loadMoreFailure,
    this.recommendationsSource = DataSource.remote,
    this.isRefreshing = false,
    this.refreshFailed = false,
  });

  final RequestStatus featuredStatus;
  final List<PropertyEntity> featured;
  final Failure? featuredFailure;

  /// A failure only leaves the "All" chip; it is retried together with the
  /// recommendations.
  final RequestStatus categoriesStatus;
  final List<CategoryEntity> categories;

  /// `null` selects "All".
  final String? selectedCategorySlug;

  final RequestStatus recommendationsStatus;

  /// Every loaded page, unique ids.
  final List<PropertyEntity> recommendations;
  final Failure? recommendationsFailure;

  /// Index of the last loaded page.
  final int recommendationsPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  /// The next page failed; loaded items stay and a retry is offered.
  final Failure? loadMoreFailure;

  /// [DataSource.saved]: the persisted "All" first page, shown after a remote
  /// failure.
  final DataSource recommendationsSource;

  /// A refresh is in progress (the user's pull or a reconnect).
  final bool isRefreshing;

  /// The last refresh couldn't update content that was already shown.
  final bool refreshFailed;

  bool get canLoadMore =>
      recommendationsStatus == RequestStatus.success &&
      !hasReachedMax &&
      !isLoadingMore &&
      loadMoreFailure == null &&
      recommendationsSource == DataSource.remote &&
      !isRefreshing;

  /// Display name for a category slug, used by the card location fallback.
  String? categoryNameFor(String slug) {
    for (final category in categories) {
      if (category.slug == slug) return category.name;
    }
    return null;
  }

  HomeState copyWith({
    RequestStatus? featuredStatus,
    List<PropertyEntity>? featured,
    ValueGetter<Failure?>? featuredFailure,
    RequestStatus? categoriesStatus,
    List<CategoryEntity>? categories,
    ValueGetter<String?>? selectedCategorySlug,
    RequestStatus? recommendationsStatus,
    List<PropertyEntity>? recommendations,
    ValueGetter<Failure?>? recommendationsFailure,
    int? recommendationsPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    ValueGetter<Failure?>? loadMoreFailure,
    DataSource? recommendationsSource,
    bool? isRefreshing,
    bool? refreshFailed,
  }) => HomeState(
    featuredStatus: featuredStatus ?? this.featuredStatus,
    featured: featured ?? this.featured,
    featuredFailure: featuredFailure != null
        ? featuredFailure()
        : this.featuredFailure,
    categoriesStatus: categoriesStatus ?? this.categoriesStatus,
    categories: categories ?? this.categories,
    selectedCategorySlug: selectedCategorySlug != null
        ? selectedCategorySlug()
        : this.selectedCategorySlug,
    recommendationsStatus: recommendationsStatus ?? this.recommendationsStatus,
    recommendations: recommendations ?? this.recommendations,
    recommendationsFailure: recommendationsFailure != null
        ? recommendationsFailure()
        : this.recommendationsFailure,
    recommendationsPage: recommendationsPage ?? this.recommendationsPage,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailure: loadMoreFailure != null
        ? loadMoreFailure()
        : this.loadMoreFailure,
    recommendationsSource: recommendationsSource ?? this.recommendationsSource,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    refreshFailed: refreshFailed ?? this.refreshFailed,
  );

  @override
  List<Object?> get props => [
    featuredStatus,
    featured,
    featuredFailure,
    categoriesStatus,
    categories,
    selectedCategorySlug,
    recommendationsStatus,
    recommendations,
    recommendationsFailure,
    recommendationsPage,
    hasReachedMax,
    isLoadingMore,
    loadMoreFailure,
    recommendationsSource,
    isRefreshing,
    refreshFailed,
  ];
}
