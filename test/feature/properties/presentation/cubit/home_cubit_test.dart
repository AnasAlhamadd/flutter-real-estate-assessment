import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_by_category_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_properties_repository.dart';
import '../../../../helpers/mocks.dart';

const _failure = NetworkFailure();
final _beauty = sampleProperties.where((p) => p.category == 'beauty').toList();
final _furniture = sampleProperties
    .where((p) => p.category == 'furniture')
    .toList();

void main() {
  late MockGetFeaturedPropertiesUseCase getFeatured;
  late MockGetCategoriesUseCase getCategories;
  late MockGetPropertiesUseCase getProperties;
  late MockGetPropertiesByCategoryUseCase getByCategory;

  setUpAll(() {
    registerFallbackValue(const FeaturedParams(limit: 1));
    registerFallbackValue(const NoParams());
    registerFallbackValue(const PageParams(page: 0));
    registerFallbackValue(const CategoryPageParams(categorySlug: '', page: 0));
  });

  setUp(() {
    getFeatured = MockGetFeaturedPropertiesUseCase();
    getCategories = MockGetCategoriesUseCase();
    getProperties = MockGetPropertiesUseCase();
    getByCategory = MockGetPropertiesByCategoryUseCase();
    when(
      () => getFeatured(any()),
    ).thenAnswer((_) async => const Right(sampleProperties));
    when(
      () => getCategories(any()),
    ).thenAnswer((_) async => const Right(sampleCategories));
    when(
      () => getProperties(any()),
    ).thenAnswer((_) async => Right(pageOf(sampleProperties)));
    when(() => getByCategory(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.first as CategoryPageParams;
      return Right(
        pageOf(
          sampleProperties
              .where((p) => p.category == params.categorySlug)
              .toList(),
        ),
      );
    });
  });

  HomeCubit build() => HomeCubit(
    getFeaturedProperties: getFeatured,
    getCategories: getCategories,
    getProperties: getProperties,
    getPropertiesByCategory: getByCategory,
  );

  const loaded = HomeState(
    featuredStatus: RequestStatus.success,
    featured: sampleProperties,
    categoriesStatus: RequestStatus.success,
    categories: sampleCategories,
    recommendationsStatus: RequestStatus.success,
    recommendations: sampleProperties,
  );

  test('starts with every section in the initial status', () {
    expect(build().state, const HomeState());
  });

  group('load', () {
    blocTest<HomeCubit, HomeState>(
      'shows loading, then the data of every section',
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => const [
        HomeState(featuredStatus: RequestStatus.loading),
        HomeState(
          featuredStatus: RequestStatus.loading,
          categoriesStatus: RequestStatus.loading,
        ),
        HomeState(
          featuredStatus: RequestStatus.loading,
          categoriesStatus: RequestStatus.loading,
          recommendationsStatus: RequestStatus.loading,
        ),
        HomeState(
          featuredStatus: RequestStatus.success,
          featured: sampleProperties,
          categoriesStatus: RequestStatus.loading,
          recommendationsStatus: RequestStatus.loading,
        ),
        HomeState(
          featuredStatus: RequestStatus.success,
          featured: sampleProperties,
          categoriesStatus: RequestStatus.success,
          categories: sampleCategories,
          recommendationsStatus: RequestStatus.loading,
        ),
        loaded,
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'requests the approved Featured count and the "All" first page',
      build: build,
      act: (cubit) => cubit.load(),
      verify: (_) {
        verify(
          () =>
              getFeatured(const FeaturedParams(limit: HomeCubit.featuredLimit)),
        ).called(1);
        verify(() => getProperties(const PageParams(page: 0))).called(1);
        verifyNever(() => getByCategory(any()));
        expect(HomeCubit.featuredLimit, 5);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'a Featured failure leaves the other sections loaded',
      setUp: () => when(
        () => getFeatured(any()),
      ).thenAnswer((_) async => const Left(_failure)),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(
        cubit.state,
        loaded.copyWith(
          featuredStatus: RequestStatus.failure,
          featured: const [],
          featuredFailure: () => _failure,
        ),
      ),
    );

    blocTest<HomeCubit, HomeState>(
      'a recommendations failure keeps Featured and the chips',
      setUp: () => when(
        () => getProperties(any()),
      ).thenAnswer((_) async => const Left(_failure)),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(
        cubit.state,
        loaded.copyWith(
          recommendationsStatus: RequestStatus.failure,
          recommendations: const [],
          recommendationsFailure: () => _failure,
        ),
      ),
    );

    blocTest<HomeCubit, HomeState>(
      'a categories failure leaves only "All" and keeps the grid',
      setUp: () => when(
        () => getCategories(any()),
      ).thenAnswer((_) async => const Left(_failure)),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(
        cubit.state,
        loaded.copyWith(
          categoriesStatus: RequestStatus.failure,
          categories: const [],
        ),
      ),
    );

    blocTest<HomeCubit, HomeState>(
      'empty lists become the empty status',
      setUp: () {
        when(() => getFeatured(any())).thenAnswer((_) async => const Right([]));
        when(
          () => getProperties(any()),
        ).thenAnswer((_) async => Right(pageOf(const [])));
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.featuredStatus, RequestStatus.empty);
        expect(cubit.state.recommendationsStatus, RequestStatus.empty);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'flags recommendations served from the persisted first page',
      setUp: () => when(() => getProperties(any())).thenAnswer(
        (_) async => Right(pageOf(sampleProperties, isFromCache: true)),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.isFromCache, isTrue),
    );
  });

  group('selectCategory', () {
    blocTest<HomeCubit, HomeState>(
      'loads the first page of that category',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.selectCategory('furniture'),
      expect: () => [
        loaded.copyWith(selectedCategorySlug: () => 'furniture'),
        loaded.copyWith(
          selectedCategorySlug: () => 'furniture',
          recommendationsStatus: RequestStatus.loading,
          recommendations: const [],
        ),
        loaded.copyWith(
          selectedCategorySlug: () => 'furniture',
          recommendations: _furniture,
        ),
      ],
      verify: (_) {
        verify(
          () => getByCategory(
            const CategoryPageParams(categorySlug: 'furniture', page: 0),
          ),
        ).called(1);
        verifyNever(() => getProperties(any()));
      },
    );

    blocTest<HomeCubit, HomeState>(
      'ignores the category that is already selected',
      build: build,
      seed: () => loaded.copyWith(selectedCategorySlug: () => 'beauty'),
      act: (cubit) => cubit.selectCategory('beauty'),
      expect: () => const <HomeState>[],
      verify: (_) => verifyNever(() => getByCategory(any())),
    );

    blocTest<HomeCubit, HomeState>(
      '"All" goes back to the paged listing',
      build: build,
      seed: () => loaded.copyWith(
        selectedCategorySlug: () => 'beauty',
        recommendations: _beauty,
      ),
      act: (cubit) => cubit.selectCategory(null),
      verify: (cubit) {
        expect(cubit.state, loaded);
        verify(() => getProperties(const PageParams(page: 0))).called(1);
      },
    );

    test('a slow response for an older selection is dropped', () async {
      final slowBeauty = Completer<Either<Failure, PropertiesPageEntity>>();
      when(
        () => getByCategory(
          const CategoryPageParams(categorySlug: 'beauty', page: 0),
        ),
      ).thenAnswer((_) => slowBeauty.future);
      final cubit = build()..emit(loaded);
      addTearDown(cubit.close);

      unawaited(cubit.selectCategory('beauty'));
      await cubit.selectCategory('furniture');
      slowBeauty.complete(Right(pageOf(_beauty)));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.selectedCategorySlug, 'furniture');
      expect(cubit.state.recommendations, _furniture);
      expect(cubit.state.recommendationsStatus, RequestStatus.success);
    });
  });

  group('retry', () {
    blocTest<HomeCubit, HomeState>(
      'retryFeatured reloads only Featured',
      build: build,
      seed: () => loaded.copyWith(
        featuredStatus: RequestStatus.failure,
        featured: const [],
        featuredFailure: () => _failure,
      ),
      act: (cubit) => cubit.retryFeatured(),
      verify: (cubit) {
        expect(cubit.state, loaded);
        verifyNever(() => getProperties(any()));
        verifyNever(() => getCategories(any()));
      },
    );

    blocTest<HomeCubit, HomeState>(
      'retryRecommendations also reloads categories that failed',
      build: build,
      seed: () => loaded.copyWith(
        categoriesStatus: RequestStatus.failure,
        categories: const [],
        recommendationsStatus: RequestStatus.failure,
        recommendations: const [],
        recommendationsFailure: () => _failure,
      ),
      act: (cubit) => cubit.retryRecommendations(),
      verify: (cubit) {
        expect(cubit.state, loaded);
        verify(() => getCategories(any())).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'retryRecommendations keeps categories that loaded',
      build: build,
      seed: () => loaded.copyWith(
        recommendationsStatus: RequestStatus.failure,
        recommendations: const [],
        recommendationsFailure: () => _failure,
      ),
      act: (cubit) => cubit.retryRecommendations(),
      verify: (_) => verifyNever(() => getCategories(any())),
    );
  });

  test('does not emit after it is closed mid-request', () async {
    final pending = Completer<Either<Failure, PropertiesPageEntity>>();
    when(() => getProperties(any())).thenAnswer((_) => pending.future);
    final cubit = build();

    final loading = cubit.load();
    await cubit.close();
    pending.complete(Right(pageOf(sampleProperties)));

    await expectLater(loading, completes);
  });

  test('categoryNameFor resolves a slug to its display name', () {
    expect(loaded.categoryNameFor('furniture'), 'Furniture');
    expect(loaded.categoryNameFor('unknown'), isNull);
  });
}
