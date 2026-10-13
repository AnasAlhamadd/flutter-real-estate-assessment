import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_by_category_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sample listing items. No thumbnails, so widget tests never download.
const List<PropertyEntity> sampleProperties = [
  PropertyEntity(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    price: 9.99,
    rating: 4.94,
    category: 'beauty',
    brand: 'Essence',
  ),
  PropertyEntity(
    id: 2,
    title: 'Eyeshadow Palette with Mirror',
    price: 19.99,
    rating: 3.28,
    category: 'beauty',
  ),
  PropertyEntity(
    id: 3,
    title: 'Annibale Colombo Bed',
    price: 1899.99,
    rating: 4.14,
    category: 'furniture',
    brand: 'Annibale Colombo',
  ),
  PropertyEntity(
    id: 4,
    title: 'Wooden Bathroom Sink With Mirror',
    price: 799.99,
    rating: 3.59,
    category: 'furniture',
  ),
  PropertyEntity(
    id: 5,
    title: 'Calvin Klein CK One',
    price: 49.99,
    rating: 4.85,
    category: 'fragrances',
    brand: 'Calvin Klein',
  ),
];

const List<CategoryEntity> sampleCategories = [
  CategoryEntity(slug: 'beauty', name: 'Beauty'),
  CategoryEntity(slug: 'fragrances', name: 'Fragrances'),
  CategoryEntity(slug: 'furniture', name: 'Furniture'),
];

PropertiesPageEntity pageOf(
  List<PropertyEntity> items, {
  bool isFromCache = false,
}) => PropertiesPageEntity(
  items: items,
  total: items.length,
  hasReachedMax: true,
  isFromCache: isFromCache,
);

/// In-memory [PropertiesRepository] for widget tests. Every result can be
/// replaced between calls; [gate] holds every response until it completes,
/// so loading states can be observed.
class FakePropertiesRepository implements PropertiesRepository {
  FakePropertiesRepository({
    this.featured = const Right(sampleProperties),
    this.categories = const Right(sampleCategories),
    Either<Failure, PropertiesPageEntity>? firstPage,
    this.categoryPages = const {},
  }) : firstPage = firstPage ?? Right(pageOf(sampleProperties));

  Either<Failure, List<PropertyEntity>> featured;
  Either<Failure, List<CategoryEntity>> categories;
  Either<Failure, PropertiesPageEntity> firstPage;

  /// Results by category slug. Unknown slugs return an empty page.
  Map<String, Either<Failure, PropertiesPageEntity>> categoryPages;

  Future<void>? gate;

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
  Future<Either<Failure, PropertiesPageEntity>> getProperties({
    required int page,
  }) async {
    await gate;
    return firstPage;
  }

  @override
  Future<Either<Failure, PropertiesPageEntity>> getPropertiesByCategory({
    required String categorySlug,
    required int page,
  }) async {
    await gate;
    return categoryPages[categorySlug] ?? Right(pageOf(const []));
  }

  @override
  Future<Either<Failure, PropertiesPageEntity>> searchProperties({
    required String query,
    CancellationSignal? cancellation,
  }) => throw UnimplementedError('Not used by Home');

  @override
  Future<Either<Failure, PropertiesPageEntity>> getAllProperties({
    CancellationSignal? cancellation,
  }) => throw UnimplementedError('Not used by Home');

  @override
  Future<Either<Failure, PropertyEntity>> getPropertyDetails(int id) =>
      throw UnimplementedError('Not used by Home');
}

HomeCubit homeCubitFor(PropertiesRepository repository) => HomeCubit(
  getFeaturedProperties: GetFeaturedPropertiesUseCase(repository),
  getCategories: GetCategoriesUseCase(repository),
  getProperties: GetPropertiesUseCase(repository),
  getPropertiesByCategory: GetPropertiesByCategoryUseCase(repository),
);

/// Registers what routed screens resolve from GetIt, backed by [repository].
/// GetIt is reset after the test.
void registerScreenDependencies(PropertiesRepository repository) {
  sl.registerFactory<HomeCubit>(() => homeCubitFor(repository));
  addTearDown(sl.reset);
}
