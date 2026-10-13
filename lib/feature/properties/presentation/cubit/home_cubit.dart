import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_by_category_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/cubit/home_state.dart';

/// Home: Featured (top rated), category chips, and the first page of
/// recommendations for the selected category. "See All" leads to Explore for
/// the full, paginated list.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this._getFeaturedProperties,
    required this._getCategories,
    required this._getProperties,
    required this._getPropertiesByCategory,
  }) : super(const HomeState());

  /// Featured count (Q18, approved 2026-10-13).
  static const int featuredLimit = 5;

  final GetFeaturedPropertiesUseCase _getFeaturedProperties;
  final GetCategoriesUseCase _getCategories;
  final GetPropertiesUseCase _getProperties;
  final GetPropertiesByCategoryUseCase _getPropertiesByCategory;

  /// Increments per recommendations request, so a slow response for a
  /// previously selected category can't overwrite the current one.
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
    final slug = state.selectedCategorySlug;
    emit(
      state.copyWith(
        recommendationsStatus: RequestStatus.loading,
        recommendations: const [],
        recommendationsFailure: () => null,
        isFromCache: false,
      ),
    );
    final result = slug == null
        ? await _getProperties(const PageParams(page: 0))
        : await _getPropertiesByCategory(
            CategoryPageParams(categorySlug: slug, page: 0),
          );
    if (isClosed || request != _recommendationsRequest) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          recommendationsStatus: RequestStatus.failure,
          recommendationsFailure: () => failure,
        ),
        (page) => state.copyWith(
          recommendationsStatus: page.items.isEmpty
              ? RequestStatus.empty
              : RequestStatus.success,
          recommendations: page.items,
          isFromCache: page.isFromCache,
        ),
      ),
    );
  }
}
