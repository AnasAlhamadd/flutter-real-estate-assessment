import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/constant/storage_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/repositories/home_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/mocks.dart';

void main() {
  final now = DateTime.utc(2026, 10, 13, 12);
  final firstPage = PropertiesResponseModel.fromJson(
    fixtureMap('products_page.json'),
  );
  final categories = CategoryModel.listFromJson(fixtureList('categories.json'));

  late MockHomeRemoteDataSource remote;
  late MockHomeLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late HomeRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(firstPage);
    registerFallbackValue(<CategoryModel>[]);
  });

  setUp(() {
    remote = MockHomeRemoteDataSource();
    local = MockHomeLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = HomeRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
      clock: () => now,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => local.cacheFirstPage(any())).thenAnswer((_) async {});
    when(() => local.cacheCategories(any())).thenAnswer((_) async {});
  });

  void stubFirstPage(Future<PropertiesResponseModel> Function() answer) => when(
    () => remote.getProducts(limit: 20, skip: 0),
  ).thenAnswer((_) => answer());

  void stubCachedFirstPage({required Duration age}) =>
      when(() => local.getFirstPage()).thenAnswer(
        (_) async => CachedEntry(data: firstPage, cachedAt: now.subtract(age)),
      );

  PropertiesPageEntity rightValue(
    Either<Failure, PropertiesPageEntity> result,
  ) => result.getOrElse(() => throw StateError('Expected Right: $result'));

  group('"All" recommendations', () {
    test('page 0 online returns fresh data and caches it', () async {
      stubFirstPage(() async => firstPage);

      final page = rightValue(await repository.getRecommendations(page: 0));

      expect(page.items, hasLength(20));
      expect(page.isFromCache, isFalse);
      verify(() => local.cacheFirstPage(firstPage)).called(1);
      verifyNever(() => local.getFirstPage());
    });

    test('page 0 still succeeds when the cache write fails', () async {
      stubFirstPage(() async => firstPage);
      when(() => local.cacheFirstPage(any())).thenThrow(const CacheException());

      final result = await repository.getRecommendations(page: 0);

      expect(rightValue(result).items, hasLength(20));
    });

    test('page 0 still succeeds when the page cannot be serialized', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      const unencodable = PropertiesResponseModel(
        products: [
          PropertyModel(
            id: 1,
            title: 'Odd',
            price: double.nan,
            rating: 0,
            category: 'beauty',
          ),
        ],
        total: 1,
        skip: 0,
        limit: 1,
      );
      stubFirstPage(() async => unencodable);

      final result = await HomeRepositoryImpl(
        remote: remote,
        local: HomeLocalDataSourceImpl(preferences),
        networkInfo: networkInfo,
      ).getRecommendations(page: 0);

      expect(rightValue(result).items.single.id, 1);
      expect(preferences.containsKey(StorageKeys.productsFirstPage), isFalse);
    });

    test('later pages use skip and are never cached', () async {
      when(
        () => remote.getProducts(limit: 20, skip: 40),
      ).thenAnswer((_) async => firstPage);

      await repository.getRecommendations(page: 2);

      verifyNever(() => local.cacheFirstPage(any()));
    });

    test('later pages never fall back to the cache', () async {
      when(
        () => remote.getProducts(limit: 20, skip: 20),
      ).thenThrow(const NetworkException());

      final result = await repository.getRecommendations(page: 1);

      expect(result, const Left(NetworkFailure()));
      verifyNever(() => local.getFirstPage());
    });

    test(
      'offline page 0 serves a fresh cache without calling the API',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        stubCachedFirstPage(age: const Duration(hours: 1));

        final page = rightValue(await repository.getRecommendations(page: 0));

        expect(page.isFromCache, isTrue);
        expect(page.cachedAt, now.subtract(const Duration(hours: 1)));
        verifyZeroInteractions(remote);
      },
    );

    final fallbackCases = <Exception, Failure>{
      const NetworkException(): const NetworkFailure(),
      const RequestTimeoutException(): const TimeoutFailure(),
      const ServerException(statusCode: 400): const RequestFailure(
        statusCode: 400,
      ),
      const ServerException(statusCode: 404): const NotFoundFailure(),
      const ServerException(statusCode: 503): const ServerFailure(
        statusCode: 503,
      ),
      const ParsingException(): const UnexpectedResponseFailure(),
      Exception('boom'): const UnknownFailure(),
    };

    fallbackCases.forEach((exception, failure) {
      test('falls back to the cache on $failure', () async {
        stubFirstPage(() => throw exception);
        stubCachedFirstPage(age: const Duration(minutes: 5));

        final page = rightValue(await repository.getRecommendations(page: 0));

        expect(page.isFromCache, isTrue);
      });

      test('returns $failure when no cache exists', () async {
        stubFirstPage(() => throw exception);
        when(() => local.getFirstPage()).thenThrow(const CacheException());

        expect(await repository.getRecommendations(page: 0), Left(failure));
      });
    });

    test('a cancelled request never falls back to the cache', () async {
      stubFirstPage(() => throw const RequestCancelledException());
      stubCachedFirstPage(age: const Duration(minutes: 5));

      expect(
        await repository.getRecommendations(page: 0),
        const Left(CancelledFailure()),
      );
      verifyNever(() => local.getFirstPage());
    });

    test('ignores a cache that is 24 hours old', () async {
      stubFirstPage(() => throw const NetworkException());
      stubCachedFirstPage(age: const Duration(hours: 24));

      expect(
        await repository.getRecommendations(page: 0),
        const Left(NetworkFailure()),
      );
    });

    test('ignores a cache timestamped in the future', () async {
      stubFirstPage(() => throw const NetworkException());
      stubCachedFirstPage(age: const Duration(hours: -1));

      expect(
        await repository.getRecommendations(page: 0),
        const Left(NetworkFailure()),
      );
    });
  });

  group('category recommendations', () {
    test('use skip and never touch the cache', () async {
      final empty = PropertiesResponseModel.fromJson(
        fixtureMap('category_unknown.json'),
      );
      when(
        () => remote.getProductsByCategory('unknown-slug', limit: 20, skip: 20),
      ).thenAnswer((_) async => empty);

      final page = rightValue(
        await repository.getRecommendations(
          categorySlug: 'unknown-slug',
          page: 1,
        ),
      );

      expect(page.items, isEmpty);
      expect(page.hasReachedMax, isTrue);
      verifyZeroInteractions(local);
    });

    test('a failed first page returns the failure, not the "All" cache', () {
      when(
        () => remote.getProductsByCategory('beauty', limit: 20, skip: 0),
      ).thenThrow(const NetworkException());

      expect(
        repository.getRecommendations(categorySlug: 'beauty', page: 0),
        completion(const Left<Failure, PropertiesPageEntity>(NetworkFailure())),
      );
    });
  });

  group('featured', () {
    test('returns the items and forwards the limit', () async {
      when(() => remote.getFeaturedProducts(limit: 5)).thenAnswer(
        (_) async =>
            PropertiesResponseModel.fromJson(fixtureMap('featured.json')),
      );

      final result = await repository.getFeaturedProperties(limit: 5);

      final items = result.getOrElse(() => throw StateError('$result'));
      expect(items.map((item) => item.id), [99, 80, 95, 42, 33]);
      verifyZeroInteractions(local);
    });

    test('offline fails fast with NetworkFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      expect(
        await repository.getFeaturedProperties(limit: 5),
        const Left(NetworkFailure()),
      );
      verifyZeroInteractions(remote);
    });
  });

  group('getCategories', () {
    void stubStoredCategories({required Duration age}) =>
        when(() => local.getCategories()).thenAnswer(
          (_) async =>
              CachedEntry(data: categories, cachedAt: now.subtract(age)),
        );

    test('serves fresh persisted categories without a request', () async {
      stubStoredCategories(age: const Duration(hours: 2));

      final result = await repository.getCategories();

      expect(result.map((list) => list.length), const Right<Failure, int>(24));
      verifyZeroInteractions(remote);
    });

    test('keeps categories in memory after the first load', () async {
      stubStoredCategories(age: const Duration(hours: 2));

      await repository.getCategories();
      await repository.getCategories();

      verify(() => local.getCategories()).called(1);
    });

    test('refreshes stale categories from the API and saves them', () async {
      stubStoredCategories(age: const Duration(hours: 25));
      when(() => remote.getCategories()).thenAnswer((_) async => categories);

      await repository.getCategories();

      verify(() => remote.getCategories()).called(1);
      verify(() => local.cacheCategories(categories)).called(1);
    });

    test('uses stale categories when the refresh fails', () async {
      stubStoredCategories(age: const Duration(days: 7));
      when(
        () => remote.getCategories(),
      ).thenThrow(const ServerException(statusCode: 404));

      final result = await repository.getCategories();

      expect(result.map((list) => list.length), const Right<Failure, int>(24));
    });

    test('fails when nothing is stored and the API fails', () async {
      when(() => local.getCategories()).thenThrow(const CacheException());
      when(
        () => remote.getCategories(),
      ).thenThrow(const RequestTimeoutException());

      expect(await repository.getCategories(), const Left(TimeoutFailure()));
    });
  });
}
