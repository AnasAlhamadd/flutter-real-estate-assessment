import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_by_category_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/search_properties_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const page = PropertiesPageEntity(items: [], total: 0, hasReachedMax: true);
  const property = PropertyEntity(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    price: 9.99,
    rating: 2.56,
    category: 'beauty',
  );
  late MockPropertiesRepository repository;

  setUpAll(() => registerFallbackValue(CancellationSignal()));

  setUp(() => repository = MockPropertiesRepository());

  group('SearchPropertiesUseCase', () {
    test('trims the query and forwards the cancellation signal', () async {
      final signal = CancellationSignal();
      when(
        () => repository.searchProperties(query: 'phone', cancellation: signal),
      ).thenAnswer((_) async => const Right(page));

      final result = await SearchPropertiesUseCase(repository)(
        SearchParams(query: '  phone ', cancellation: signal),
      );

      expect(result, const Right<Failure, PropertiesPageEntity>(page));
      verifyNever(
        () => repository.getAllProperties(
          cancellation: any(named: 'cancellation'),
        ),
      );
    });

    test('a blank query loads the whole catalog', () async {
      when(
        () => repository.getAllProperties(
          cancellation: any(named: 'cancellation'),
        ),
      ).thenAnswer((_) async => const Right(page));

      await SearchPropertiesUseCase(repository)(
        const SearchParams(query: '  '),
      );

      verify(
        () => repository.getAllProperties(
          cancellation: any(named: 'cancellation'),
        ),
      ).called(1);
      verifyNever(
        () => repository.searchProperties(
          query: any(named: 'query'),
          cancellation: any(named: 'cancellation'),
        ),
      );
    });
  });

  test('GetPropertiesUseCase forwards the page', () async {
    when(
      () => repository.getProperties(page: 3),
    ).thenAnswer((_) async => const Right(page));

    await GetPropertiesUseCase(repository)(const PageParams(page: 3));

    verify(() => repository.getProperties(page: 3)).called(1);
  });

  test('GetPropertiesByCategoryUseCase forwards slug and page', () async {
    when(
      () =>
          repository.getPropertiesByCategory(categorySlug: 'laptops', page: 1),
    ).thenAnswer((_) async => const Right(page));

    await GetPropertiesByCategoryUseCase(repository)(
      const CategoryPageParams(categorySlug: 'laptops', page: 1),
    );

    verify(
      () =>
          repository.getPropertiesByCategory(categorySlug: 'laptops', page: 1),
    ).called(1);
  });

  test('GetFeaturedPropertiesUseCase forwards the limit', () async {
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

  test('GetPropertyDetailsUseCase forwards the id and failures', () async {
    when(
      () => repository.getPropertyDetails(7),
    ).thenAnswer((_) async => const Left(NotFoundFailure()));

    final result = await GetPropertyDetailsUseCase(repository)(
      const PropertyDetailsParams(id: 7),
    );

    expect(result, const Left<Failure, PropertyEntity>(NotFoundFailure()));
  });
}
