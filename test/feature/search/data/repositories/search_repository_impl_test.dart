import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_real_estate_assessment/feature/search/data/datasource/search_results_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/search/data/repositories/search_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

const _query = 'phone';
const _pageSize = SearchRepositoryImpl.pageSize;

PropertiesResponseModel _page(List<int> ids, {int skip = 0, int? total}) =>
    PropertiesResponseModel(
      products: [
        for (final id in ids)
          PropertyModel(
            id: id,
            title: 'Product $id',
            price: 10,
            rating: 4,
            category: 'smartphones',
          ),
      ],
      total: total ?? ids.length,
      skip: skip,
      limit: ids.length,
    );

List<int> _ids(Either<Failure, SearchResultsEntity> result) =>
    result.fold((_) => const [], (r) => r.items.map((p) => p.id).toList());

SearchResultsEntity _right(Either<Failure, SearchResultsEntity> result) =>
    result.getOrElse(() => throw StateError('expected Right, got $result'));

void main() {
  late MockPropertiesRemoteDataSource remote;
  late MockNetworkInfo networkInfo;
  late SearchResultsMemoryDataSource local;
  late DateTime now;
  late SearchRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(CancellationSignal()));

  setUp(() {
    remote = MockPropertiesRemoteDataSource();
    networkInfo = MockNetworkInfo();
    local = SearchResultsMemoryDataSource();
    now = DateTime.utc(2026, 10, 14, 9);
    repository = SearchRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
      clock: () => now,
    );
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  });

  void stubSearch(
    PropertiesResponseModel page, {
    int skip = 0,
    int limit = _pageSize,
  }) {
    when(
      () => remote.searchProductsPage(
        _query,
        skip: skip,
        limit: limit,
        cancellation: any(named: 'cancellation'),
      ),
    ).thenAnswer((_) async => page);
  }

  void stubSearchError(Exception error) {
    when(
      () => remote.searchProductsPage(
        any(),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
        cancellation: any(named: 'cancellation'),
      ),
    ).thenThrow(error);
  }

  void verifyNoSearch() => verifyNever(
    () => remote.searchProductsPage(
      any(),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
      cancellation: any(named: 'cancellation'),
    ),
  );

  group('searchFirstPage', () {
    test('returns NetworkFailure without a request when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.searchFirstPage(_query);

      expect(
        result,
        const Left<Failure, SearchResultsEntity>(NetworkFailure()),
      );
      verifyNoSearch();
    });

    test('fetches the first page and reports the API total', () async {
      stubSearch(_page([1, 2], total: 45));

      final results = _right(await repository.searchFirstPage(_query));

      expect(results.query, _query);
      expect(results.items.map((p) => p.id), [1, 2]);
      expect(results.total, 45);
      expect(results.hasReachedMax, isFalse);
      expect(results.isStale, isFalse);
    });

    test('passes the cancellation signal to the request', () async {
      final signal = CancellationSignal();
      stubSearch(_page([1]));

      await repository.searchFirstPage(_query, cancellation: signal);

      verify(
        () => remote.searchProductsPage(
          _query,
          skip: 0,
          limit: _pageSize,
          cancellation: signal,
        ),
      ).called(1);
    });

    test('serves a cached query again without a request', () async {
      stubSearch(_page([1, 2], total: 45));
      await repository.searchFirstPage(_query);
      clearInteractions(remote);

      final result = await repository.searchFirstPage(_query);

      expect(_ids(result), [1, 2]);
      verifyNoSearch();
    });

    test('caches an empty result as a finished answer', () async {
      stubSearch(_page([]));

      final results = _right(await repository.searchFirstPage(_query));

      expect(results.items, isEmpty);
      expect(results.hasReachedMax, isTrue);
      expect(repository.cachedResults(_query), isNotNull);
    });

    test('maps a server error and caches nothing', () async {
      stubSearchError(const ServerException(statusCode: 500));

      final result = await repository.searchFirstPage(_query);

      expect(
        result,
        const Left<Failure, SearchResultsEntity>(
          ServerFailure(statusCode: 500),
        ),
      );
      expect(repository.cachedResults(_query), isNull);
    });

    test('maps a timeout to TimeoutFailure', () async {
      stubSearchError(const RequestTimeoutException());

      final result = await repository.searchFirstPage(_query);

      expect(
        result,
        const Left<Failure, SearchResultsEntity>(TimeoutFailure()),
      );
    });

    test('maps a cancelled request to CancelledFailure', () async {
      stubSearchError(const RequestCancelledException());

      final result = await repository.searchFirstPage(_query);

      expect(
        result,
        const Left<Failure, SearchResultsEntity>(CancelledFailure()),
      );
    });

    test('flags a cached query as stale after the freshness window', () async {
      stubSearch(_page([1], total: 45));
      await repository.searchFirstPage(_query);

      now = now.add(
        SearchResultsMemoryDataSource.defaultFreshFor +
            const Duration(minutes: 1),
      );

      expect(repository.cachedResults(_query)?.isStale, isTrue);
    });
  });

  group('loadNextPage', () {
    test('loads the first page when nothing is cached', () async {
      stubSearch(_page([1, 2], total: 45));

      final result = await repository.loadNextPage(_query);

      expect(_ids(result), [1, 2]);
    });

    test('requests the next offset and appends in API order', () async {
      stubSearch(_page([1, 2], total: 4));
      await repository.searchFirstPage(_query);
      stubSearch(_page([3, 4], skip: 2, total: 4), skip: 2);

      final results = _right(await repository.loadNextPage(_query));

      expect(results.items.map((p) => p.id), [1, 2, 3, 4]);
      expect(results.hasReachedMax, isTrue);
    });

    test('drops ids a later page repeats', () async {
      stubSearch(_page([1, 2], total: 6));
      await repository.searchFirstPage(_query);
      stubSearch(_page([2, 3], skip: 2, total: 6), skip: 2);

      final result = await repository.loadNextPage(_query);

      expect(_ids(result), [1, 2, 3]);
    });

    test('sends nothing once the last page is loaded', () async {
      stubSearch(_page([1, 2]));
      await repository.searchFirstPage(_query);
      clearInteractions(remote);

      final result = await repository.loadNextPage(_query);

      expect(_ids(result), [1, 2]);
      verifyNoSearch();
    });

    test('a failed page keeps the loaded pages', () async {
      stubSearch(_page([1, 2], total: 45));
      await repository.searchFirstPage(_query);
      stubSearchError(const NetworkException());

      final result = await repository.loadNextPage(_query);

      expect(
        result,
        const Left<Failure, SearchResultsEntity>(NetworkFailure()),
      );
      expect(repository.cachedResults(_query)?.items.map((p) => p.id), [1, 2]);
    });
  });

  group('refreshResults', () {
    test('fetches the loaded range in one request and replaces it', () async {
      stubSearch(_page([for (var i = 1; i <= 20; i++) i], total: 45));
      await repository.searchFirstPage(_query);
      stubSearch(
        _page([for (var i = 21; i <= 40; i++) i], skip: 20, total: 45),
        skip: 20,
      );
      await repository.loadNextPage(_query);
      stubSearch(_page([99, 98], total: 2), limit: 40);

      final results = _right(await repository.refreshResults(_query));

      expect(results.items.map((p) => p.id), [99, 98]);
      expect(results.total, 2);
      verify(
        () => remote.searchProductsPage(
          _query,
          skip: 0,
          limit: 40,
          cancellation: any(named: 'cancellation'),
        ),
      ).called(1);
    });

    test('a failed refresh leaves the cached pages as they were', () async {
      stubSearch(_page([1, 2], total: 45));
      await repository.searchFirstPage(_query);
      stubSearchError(const ServerException(statusCode: 503));

      final result = await repository.refreshResults(_query);

      expect(result.isLeft(), isTrue);
      expect(repository.cachedResults(_query)?.items.map((p) => p.id), [1, 2]);
    });
  });
}
