import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Home has three independent sections, so a failure in one never hides the
/// others: Featured, the category chips, and the recommendation grid.
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
    this.isFromCache = false,
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
  final List<PropertyEntity> recommendations;
  final Failure? recommendationsFailure;

  /// The recommendations are the persisted "All" first page, shown after a
  /// remote failure.
  final bool isFromCache;

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
    bool? isFromCache,
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
    isFromCache: isFromCache ?? this.isFromCache,
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
    isFromCache,
  ];
}
