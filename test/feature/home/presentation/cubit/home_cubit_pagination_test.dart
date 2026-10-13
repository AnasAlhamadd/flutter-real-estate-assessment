import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_featured_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/mocks.dart';

typedef _PageResult = Either<Failure, PropertiesPageEntity>;

const _failure = NetworkFailure();

PropertyEntity _item(int id) => PropertyEntity(
  id: id,
  title: 'Item $id',
  price: id.toDouble(),
  rating: 4,
  category: 'beauty',
);

final _firstPage = [for (var id = 1; id <= 4; id++) _item(id)];
final _secondPage = [for (var id = 5; id <= 8; id++) _item(id)];
final _refreshed = [for (var id = 11; id <= 14; id++) _item(id)];

const _page0 = RecommendationsParams(page: 0);
const _page1 = RecommendationsParams(page: 1);

Future<void> _flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late MockGetFeaturedPropertiesUseCase getFeatured;
  late MockGetCategoriesUseCase getCategories;
  late MockGetRecommendationsUseCase getRecommendations;

  setUpAll(() {
    registerFallbackValue(const FeaturedParams(limit: 1));
    registerFallbackValue(const NoParams());
    registerFallbackValue(_page0);
  });

  void answerPage(RecommendationsParams params, _PageResult result) =>
      when(() => getRecommendations(params)).thenAnswer((_) async => result);

  setUp(() {
    getFeatured = MockGetFeaturedPropertiesUseCase();
    getCategories = MockGetCategoriesUseCase();
    getRecommendations = MockGetRecommendationsUseCase();
    when(
      () => getFeatured(any()),
    ).thenAnswer((_) async => const Right(sampleProperties));
    when(
      () => getCategories(any()),
    ).thenAnswer((_) async => const Right(sampleCategories));
    // Category pages; the "All" pages below take precedence.
    when(
      () => getRecommendations(any()),
    ).thenAnswer((_) async => Right(pageOf(_firstPage, hasReachedMax: false)));
    answerPage(_page0, Right(pageOf(_firstPage, hasReachedMax: false)));
    answerPage(_page1, Right(pageOf(_secondPage, hasReachedMax: false)));
  });

  HomeCubit build({Stream<bool>? connectivity}) => HomeCubit(
    getFeaturedProperties: getFeatured,
    getCategories: getCategories,
    getRecommendations: getRecommendations,
    connectivityChanges: connectivity,
  );

  final paged = HomeState(
    featuredStatus: RequestStatus.success,
    featured: sampleProperties,
    categoriesStatus: RequestStatus.success,
    categories: sampleCategories,
    recommendationsStatus: RequestStatus.success,
    recommendations: _firstPage,
  );

  group('canLoadMore', () {
    test('only when the grid has content and more pages', () {
      expect(paged.canLoadMore, isTrue);
      expect(paged.copyWith(hasReachedMax: true).canLoadMore, isFalse);
      expect(paged.copyWith(isLoadingMore: true).canLoadMore, isFalse);
      expect(
        paged.copyWith(loadMoreFailure: () => _failure).canLoadMore,
        isFalse,
      );
      expect(paged.copyWith(isFromCache: true).canLoadMore, isFalse);
      expect(paged.copyWith(isRefreshing: true).canLoadMore, isFalse);
      expect(
        paged
            .copyWith(recommendationsStatus: RequestStatus.loading)
            .canLoadMore,
        isFalse,
      );
    });
  });

  group('loadMore', () {
    blocTest<HomeCubit, HomeState>(
      'appends the next page and keeps the loaded items while loading',
      build: build,
      seed: () => paged,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        paged.copyWith(isLoadingMore: true),
        paged.copyWith(
          recommendations: [..._firstPage, ..._secondPage],
          recommendationsPage: 1,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'skips items whose id is already in the grid',
      setUp: () => answerPage(
        _page1,
        Right(pageOf([_item(4), _item(5), _item(5)], hasReachedMax: false)),
      ),
      build: build,
      seed: () => paged,
      act: (cubit) => cubit.loadMore(),
      verify: (cubit) => expect(
        cubit.state.recommendations.map((item) => item.id),
        [1, 2, 3, 4, 5],
      ),
    );

    blocTest<HomeCubit, HomeState>(
      'stops requesting after the last page',
      setUp: () => answerPage(_page1, Right(pageOf(_secondPage))),
      build: build,
      seed: () => paged,
      act: (cubit) async {
        await cubit.loadMore();
        await cubit.loadMore();
      },
      verify: (cubit) {
        expect(cubit.state.hasReachedMax, isTrue);
        verify(() => getRecommendations(_page1)).called(1);
        verifyNever(
          () => getRecommendations(const RecommendationsParams(page: 2)),
        );
      },
    );

    blocTest<HomeCubit, HomeState>(
      'an empty page ends the list even if the total said otherwise',
      setUp: () =>
          answerPage(_page1, Right(pageOf(const [], hasReachedMax: false))),
      build: build,
      seed: () => paged,
      act: (cubit) => cubit.loadMore(),
      verify: (cubit) => expect(cubit.state.hasReachedMax, isTrue),
    );

    test('ignores calls while a page is loading', () async {
      final pending = Completer<_PageResult>();
      when(() => getRecommendations(_page1)).thenAnswer((_) => pending.future);
      final cubit = build()..emit(paged);
      addTearDown(cubit.close);

      unawaited(cubit.loadMore());
      unawaited(cubit.loadMore());
      unawaited(cubit.loadMore());
      pending.complete(Right(pageOf(_secondPage, hasReachedMax: false)));
      await _flush();

      verify(() => getRecommendations(_page1)).called(1);
      expect(cubit.state.recommendations, hasLength(8));
    });

    blocTest<HomeCubit, HomeState>(
      'does nothing on saved results',
      build: build,
      seed: () => paged.copyWith(isFromCache: true),
      act: (cubit) => cubit.loadMore(),
      expect: () => const <HomeState>[],
      verify: (_) => verifyNever(() => getRecommendations(any())),
    );

    blocTest<HomeCubit, HomeState>(
      'pages the selected category',
      build: build,
      seed: () => paged.copyWith(selectedCategorySlug: () => 'beauty'),
      act: (cubit) => cubit.loadMore(),
      verify: (_) {
        verify(
          () => getRecommendations(
            const RecommendationsParams(categorySlug: 'beauty', page: 1),
          ),
        ).called(1);
        verifyNoMoreInteractions(getRecommendations);
      },
    );
  });

  group('load more failure', () {
    blocTest<HomeCubit, HomeState>(
      'keeps the loaded items and blocks paging until a retry',
      setUp: () => answerPage(_page1, const Left(_failure)),
      build: build,
      seed: () => paged,
      act: (cubit) async {
        await cubit.loadMore();
        await cubit.loadMore();
      },
      expect: () => [
        paged.copyWith(isLoadingMore: true),
        paged.copyWith(loadMoreFailure: () => _failure),
      ],
      verify: (_) => verify(() => getRecommendations(_page1)).called(1),
    );

    blocTest<HomeCubit, HomeState>(
      'retryLoadMore requests the same page again',
      build: build,
      seed: () => paged.copyWith(loadMoreFailure: () => _failure),
      act: (cubit) => cubit.retryLoadMore(),
      expect: () => [
        paged.copyWith(isLoadingMore: true),
        paged.copyWith(
          recommendations: [..._firstPage, ..._secondPage],
          recommendationsPage: 1,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'retryLoadMore does nothing without a failure',
      build: build,
      seed: () => paged,
      act: (cubit) => cubit.retryLoadMore(),
      expect: () => const <HomeState>[],
    );
  });

  group('category change', () {
    blocTest<HomeCubit, HomeState>(
      'starts again from the first page of the new category',
      build: build,
      seed: () => paged.copyWith(
        recommendations: [..._firstPage, ..._secondPage],
        recommendationsPage: 1,
        hasReachedMax: true,
        loadMoreFailure: () => _failure,
      ),
      act: (cubit) => cubit.selectCategory('beauty'),
      verify: (cubit) => expect(
        cubit.state,
        paged.copyWith(selectedCategorySlug: () => 'beauty'),
      ),
    );

    test('drops a next page that arrives after the change', () async {
      final pending = Completer<_PageResult>();
      when(() => getRecommendations(_page1)).thenAnswer((_) => pending.future);
      final cubit = build()..emit(paged);
      addTearDown(cubit.close);

      unawaited(cubit.loadMore());
      await cubit.selectCategory('beauty');
      pending.complete(Right(pageOf(_secondPage, hasReachedMax: false)));
      await _flush();

      expect(cubit.state.recommendations, _firstPage);
      expect(cubit.state.recommendationsPage, 0);
      expect(cubit.state.isLoadingMore, isFalse);
      expect(cubit.state.canLoadMore, isTrue);
    });
  });

  group('refresh', () {
    blocTest<HomeCubit, HomeState>(
      'replaces every section and resets paging',
      setUp: () {
        when(
          () => getFeatured(any()),
        ).thenAnswer((_) async => Right(_refreshed));
        answerPage(_page0, Right(pageOf(_refreshed, hasReachedMax: false)));
      },
      build: build,
      seed: () => paged.copyWith(
        recommendations: [..._firstPage, ..._secondPage],
        recommendationsPage: 1,
      ),
      act: (cubit) => cubit.refresh(),
      verify: (cubit) => expect(
        cubit.state,
        paged.copyWith(featured: _refreshed, recommendations: _refreshed),
      ),
    );

    blocTest<HomeCubit, HomeState>(
      'never shows a loading state over content',
      setUp: () => when(
        () => getFeatured(any()),
      ).thenAnswer((_) async => Right(_refreshed)),
      build: build,
      seed: () => paged,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        paged.copyWith(isRefreshing: true),
        paged.copyWith(isRefreshing: true, featured: _refreshed),
        paged.copyWith(featured: _refreshed),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'keeps the shown content and reports a failed request',
      setUp: () => when(
        () => getFeatured(any()),
      ).thenAnswer((_) async => const Left(_failure)),
      build: build,
      seed: () => paged,
      act: (cubit) => cubit.refresh(),
      verify: (cubit) {
        expect(cubit.state.featured, sampleProperties);
        expect(cubit.state.featuredStatus, RequestStatus.success);
        expect(cubit.state.refreshFailed, isTrue);
        expect(cubit.state.isRefreshing, isFalse);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'does not replace live results with the saved copy',
      setUp: () =>
          answerPage(_page0, Right(pageOf(_refreshed, isFromCache: true))),
      build: build,
      seed: () => paged.copyWith(
        recommendations: [..._firstPage, ..._secondPage],
        recommendationsPage: 1,
      ),
      act: (cubit) => cubit.refresh(),
      verify: (cubit) {
        expect(cubit.state.recommendations, hasLength(8));
        expect(cubit.state.isFromCache, isFalse);
        expect(cubit.state.refreshFailed, isTrue);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'loads sections that had failed',
      build: build,
      seed: () => paged.copyWith(
        featuredStatus: RequestStatus.failure,
        featured: const [],
        featuredFailure: () => _failure,
      ),
      act: (cubit) => cubit.refresh(),
      verify: (cubit) {
        expect(cubit.state.featuredStatus, RequestStatus.success);
        expect(cubit.state.featured, sampleProperties);
        expect(cubit.state.refreshFailed, isFalse);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'replaces saved results once the API answers',
      build: build,
      seed: () => paged.copyWith(isFromCache: true, hasReachedMax: true),
      act: (cubit) => cubit.refresh(),
      verify: (cubit) {
        expect(cubit.state.isFromCache, isFalse);
        expect(cubit.state.canLoadMore, isTrue);
      },
    );

    test('a second refresh while one runs is ignored', () async {
      final cubit = build()..emit(paged);
      addTearDown(cubit.close);

      await Future.wait([cubit.refresh(), cubit.refresh()]);

      verify(() => getFeatured(any())).called(1);
      verify(() => getRecommendations(_page0)).called(1);
    });

    test('drops a next page that arrives after the refresh', () async {
      final pending = Completer<_PageResult>();
      when(() => getRecommendations(_page1)).thenAnswer((_) => pending.future);
      answerPage(_page0, Right(pageOf(_refreshed, hasReachedMax: false)));
      final cubit = build()..emit(paged);
      addTearDown(cubit.close);

      unawaited(cubit.loadMore());
      await cubit.refresh();
      pending.complete(Right(pageOf(_secondPage, hasReachedMax: false)));
      await _flush();

      expect(cubit.state.recommendations, _refreshed);
      expect(cubit.state.isLoadingMore, isFalse);
    });
  });

  group('connectivity', () {
    late StreamController<bool> changes;

    setUp(() => changes = StreamController<bool>());
    tearDown(() => changes.close());

    Future<HomeCubit> cubitWith(HomeState state) async {
      final cubit = build(connectivity: changes.stream)..emit(state);
      addTearDown(cubit.close);
      return cubit;
    }

    test('coming back online refreshes a failed section once', () async {
      final cubit = await cubitWith(
        paged.copyWith(
          featuredStatus: RequestStatus.failure,
          featured: const [],
          featuredFailure: () => _failure,
        ),
      );

      changes
        ..add(false)
        ..add(true)
        ..add(true);
      await _flush();

      verify(() => getFeatured(any())).called(1);
      expect(cubit.state.featuredStatus, RequestStatus.success);
    });

    test('coming back online replaces saved results', () async {
      final cubit = await cubitWith(paged.copyWith(isFromCache: true));

      changes
        ..add(false)
        ..add(true);
      await _flush();

      expect(cubit.state.isFromCache, isFalse);
    });

    test('coming back online retries a failed next page', () async {
      final cubit = await cubitWith(
        paged.copyWith(loadMoreFailure: () => _failure),
      );

      changes
        ..add(false)
        ..add(true);
      await _flush();

      verify(() => getRecommendations(_page1)).called(1);
      verifyNever(() => getFeatured(any()));
      expect(cubit.state.recommendations, hasLength(8));
    });

    test('does nothing when the first event is online', () async {
      await cubitWith(
        paged.copyWith(
          featuredStatus: RequestStatus.failure,
          featuredFailure: () => _failure,
        ),
      );

      changes.add(true);
      await _flush();

      verifyNever(() => getFeatured(any()));
    });

    test('does nothing when every section is fine', () async {
      await cubitWith(paged);

      changes
        ..add(false)
        ..add(true);
      await _flush();

      verifyNever(() => getFeatured(any()));
      verifyNever(() => getRecommendations(any()));
    });

    test('stops listening when closed', () async {
      final cubit = build(connectivity: changes.stream);

      expect(changes.hasListener, isTrue);
      await cubit.close();
      expect(changes.hasListener, isFalse);
    });
  });
}
