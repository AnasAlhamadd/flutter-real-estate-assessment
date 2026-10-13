import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_favorites_repository.dart';
import 'fake_properties_repository.dart';
import 'sample_properties.dart';

export 'sample_properties.dart';

/// In-memory [HomeRepository] for widget tests. Every result can be
/// replaced between calls; [gate] holds every response until it completes,
/// so loading states can be observed.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.featured = const Right(sampleProperties),
    this.categories = const Right(sampleCategories),
    Either<Failure, PropertiesPageEntity>? firstPage,
    this.categoryPages = const {},
    this.nextPages = const {},
  }) : firstPage = firstPage ?? Right(pageOf(sampleProperties));

  Either<Failure, List<PropertyEntity>> featured;
  Either<Failure, List<CategoryEntity>> categories;
  Either<Failure, PropertiesPageEntity> firstPage;

  /// Results by category slug. Unknown slugs return an empty page.
  Map<String, Either<Failure, PropertiesPageEntity>> categoryPages;

  /// "All" pages after the first, by index. Missing pages are empty.
  Map<int, Either<Failure, PropertiesPageEntity>> nextPages;

  Future<void>? gate;

  /// Holds only the "All" pages after the first.
  Future<void>? nextPageGate;

  /// Every recommendations request, as `all:<page>` or `<slug>:<page>`.
  final List<String> pageRequests = [];

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties({
    required int limit,
  }) async {
    await gate;
    return featured.map((items) => items.take(limit).toList());
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    await gate;
    return categories;
  }

  @override
  Future<Either<Failure, PropertiesPageEntity>> getRecommendations({
    String? categorySlug,
    required int page,
  }) async {
    pageRequests.add('${categorySlug ?? 'all'}:$page');
    await gate;
    if (categorySlug != null) {
      if (page > 0) return Right(pageOf(const []));
      return categoryPages[categorySlug] ?? Right(pageOf(const []));
    }
    if (page == 0) return firstPage;
    await nextPageGate;
    return nextPages[page] ?? Right(pageOf(const []));
  }
}

HomeCubit homeCubitFor(HomeRepository repository) => HomeCubit(
  getFeaturedProperties: GetFeaturedPropertiesUseCase(repository),
  getCategories: GetCategoriesUseCase(repository),
  getRecommendations: GetRecommendationsUseCase(repository),
);

/// Registers what routed screens resolve from GetIt, backed by [repository],
/// [favorites] (empty in memory by default) and [properties] (sample
/// details by default). GetIt is reset after the test.
void registerScreenDependencies(
  HomeRepository repository, {
  FavoritesRepository? favorites,
  PropertiesRepository? properties,
}) {
  final favoritesRepository = favorites ?? FakeFavoritesRepository();
  final propertiesRepository = properties ?? FakePropertiesRepository();
  sl
    ..registerFactory<HomeCubit>(() => homeCubitFor(repository))
    ..registerFactory<PropertyDetailsCubit>(
      () => propertyDetailsCubitFor(propertiesRepository),
    )
    ..registerFactory<FavoritesCubit>(
      () => favoritesCubitFor(favoritesRepository),
    );
  addTearDown(sl.reset);
}
