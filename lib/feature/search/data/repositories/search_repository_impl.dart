import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exception_failure_mapper.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/data/datasource/search_results_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/repositories/search_repository.dart';

/// Cache first, then remote. Only successful responses are cached (an empty
/// result is a valid answer); failures never touch the cache.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    required this._remote,
    required this._local,
    required this._networkInfo,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const int pageSize = ApiConstants.pageSize;

  final PropertiesRemoteDataSource _remote;
  final SearchResultsLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final DateTime Function() _clock;

  @override
  SearchResultsEntity? cachedResults(String query) {
    final entry = _local.read(query);
    return entry == null ? null : _toEntity(query, entry);
  }

  @override
  Future<Either<Failure, SearchResultsEntity>> searchFirstPage(
    String query, {
    CancellationSignal? cancellation,
  }) async {
    final cached = cachedResults(query);
    if (cached != null) return Right(cached);
    final result = await _fetch(query, 0, pageSize, cancellation);
    return result.map((page) {
      // Another caller may have filled the entry while this one waited.
      final entry = _local.read(query) ?? _replace(query, page);
      return _toEntity(query, entry);
    });
  }

  @override
  Future<Either<Failure, SearchResultsEntity>> loadNextPage(
    String query, {
    CancellationSignal? cancellation,
  }) async {
    final before = _local.read(query);
    if (before == null) {
      return searchFirstPage(query, cancellation: cancellation);
    }
    if (before.hasReachedMax) return Right(_toEntity(query, before));
    final skip = before.nextSkip;
    final result = await _fetch(query, skip, pageSize, cancellation);
    return result.map((page) {
      final current = _local.read(query);
      // A refresh or a concurrent page moved the entry on: this page no
      // longer continues it, so keep the entry as it is.
      if (current == null || current.nextSkip != skip) {
        return _toEntity(query, current ?? before);
      }
      final entry = _append(current, page);
      _local.write(query, entry);
      return _toEntity(query, entry);
    });
  }

  @override
  Future<Either<Failure, SearchResultsEntity>> refreshResults(
    String query, {
    CancellationSignal? cancellation,
  }) async {
    final loaded = _local.read(query)?.nextSkip ?? 0;
    final limit = loaded > pageSize ? loaded : pageSize;
    final result = await _fetch(query, 0, limit, cancellation);
    return result.map((page) => _toEntity(query, _replace(query, page)));
  }

  Future<Either<Failure, PropertiesResponseModel>> _fetch(
    String query,
    int skip,
    int limit,
    CancellationSignal? cancellation,
  ) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(
        await _remote.searchProductsPage(
          query,
          skip: skip,
          limit: limit,
          cancellation: cancellation,
        ),
      );
    } on Exception catch (error) {
      return Left(failureFromException(error));
    }
  }

  SearchCacheEntry _replace(String query, PropertiesResponseModel page) {
    final empty = SearchCacheEntry(
      items: const [],
      total: page.total,
      nextSkip: page.skip,
      hasReachedMax: false,
      fetchedAt: _clock(),
    );
    final entry = _append(empty, page);
    _local.write(query, entry);
    return entry;
  }

  /// Adds the page's new ids after the loaded ones, in API order.
  static SearchCacheEntry _append(
    SearchCacheEntry entry,
    PropertiesResponseModel page,
  ) {
    final known = {for (final item in entry.items) item.id};
    final added = page.products
        .where((product) => known.add(product.id))
        .map((product) => product.toEntity());
    final nextSkip = page.skip + page.limit;
    return SearchCacheEntry(
      items: List<PropertyEntity>.unmodifiable([...entry.items, ...added]),
      total: page.total,
      nextSkip: nextSkip,
      // An empty page can't be continued, whatever `total` says.
      hasReachedMax: nextSkip >= page.total || page.products.isEmpty,
      fetchedAt: entry.fetchedAt,
    );
  }

  SearchResultsEntity _toEntity(String query, SearchCacheEntry entry) =>
      SearchResultsEntity(
        query: query,
        items: entry.items,
        total: entry.total,
        hasReachedMax: entry.hasReachedMax,
        isStale: _local.isStale(entry, _clock()),
      );
}
