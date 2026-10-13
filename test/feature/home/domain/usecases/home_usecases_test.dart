import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const page = PropertiesPageEntity(items: [], total: 0, hasReachedMax: true);
  late MockHomeRepository repository;

  setUp(() => repository = MockHomeRepository());

  group('GetRecommendationsUseCase', () {
    test('asks for "All" when no category is selected', () async {
      when(
        () => repository.getRecommendations(page: 3),
      ).thenAnswer((_) async => const Right(page));

      final result = await GetRecommendationsUseCase(repository)(
        const RecommendationsParams(page: 3),
      );

      expect(result, const Right<Failure, PropertiesPageEntity>(page));
      verify(() => repository.getRecommendations(page: 3)).called(1);
    });

    test('forwards the category slug and page', () async {
      when(
        () => repository.getRecommendations(categorySlug: 'laptops', page: 1),
      ).thenAnswer((_) async => const Right(page));

      await GetRecommendationsUseCase(repository)(
        const RecommendationsParams(categorySlug: 'laptops', page: 1),
      );

      verify(
        () => repository.getRecommendations(categorySlug: 'laptops', page: 1),
      ).called(1);
    });
  });

  test('GetFeaturedPropertiesUseCase forwards the limit', () async {
    const property = PropertyEntity(
      id: 1,
      title: 'Essence Mascara Lash Princess',
      price: 9.99,
      rating: 4.94,
      category: 'beauty',
    );
    when(
      () => repository.getFeaturedProperties(limit: 5),
    ).thenAnswer((_) async => const Right([property]));

    final result = await GetFeaturedPropertiesUseCase(repository)(
      const FeaturedParams(limit: 5),
    );

    expect(result, const Right<Failure, List<PropertyEntity>>([property]));
  });

  test('GetCategoriesUseCase returns the repository result', () async {
    const categories = [CategoryEntity(slug: 'beauty', name: 'Beauty')];
    when(
      () => repository.getCategories(),
    ).thenAnswer((_) async => const Right(categories));

    final result = await GetCategoriesUseCase(repository)(const NoParams());

    expect(result, const Right<Failure, List<CategoryEntity>>(categories));
  });
}
