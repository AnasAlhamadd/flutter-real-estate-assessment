import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/exception_failure_mapper.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  PropertiesRepositoryImpl({
    required this._remote,
    required this._networkInfo,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const int detailsMemoryLimit = 20;

  /// Full sets kept in memory (each at most the whole catalog, ≈ 40 KB of
  /// JSON), so the Filter sheet and the filtered results share one request.
  static const int fullSetMemoryLimit = 5;
  static const Duration fullSetFreshFor = Duration(minutes: 10);

  final PropertiesRemoteDataSource _remote;
  final NetworkInfo _networkInfo;
  final DateTime Function() _clock;

  /// Insertion-ordered, so the first key is the least recently stored.
  final LinkedHashMap<int, PropertyEntity> _details = LinkedHashMap();

  /// Least recently used first.
  final LinkedHashMap<String, _FullSet> _fullSets = LinkedHashMap();

  @override
  Future<Either<Failure, PropertiesPageEntity>> searchProperties({
    required String query,
    CancellationSignal? cancellation,
    bool forceRefresh = false,
  }) => _fullSet(
    'search:$query',
    () => _remote.searchProducts(query, cancellation: cancellation),
    forceRefresh: forceRefresh,
  );

  @override
  Future<Either<Failure, PropertiesPageEntity>> getAllProperties({
    CancellationSignal? cancellation,
    bool forceRefresh = false,
  }) => _fullSet(
    'all',
    () => _remote.getAllProducts(cancellation: cancellation),
    forceRefresh: forceRefresh,
  );

  @override
  Future<Either<Failure, PropertyEntity>> getPropertyDetails(int id) async {
    final result = await _fetch(() => _remote.getProductById(id));
    return result.fold<Either<Failure, PropertyEntity>>(
      (failure) {
        final remembered = _details[id];
        return remembered == null ? Left(failure) : Right(remembered);
      },
      (model) {
        final property = model.toEntity();
        _rememberDetails(property);
        return Right(property);
      },
    );
  }

  /// A fresh copy from memory, else the API. Only successes are kept.
  Future<Either<Failure, PropertiesPageEntity>> _fullSet(
    String key,
    Future<PropertiesResponseModel> Function() request, {
    required bool forceRefresh,
  }) async {
    final cached = _fullSets.remove(key);
    if (cached != null) _fullSets[key] = cached;
    if (cached != null &&
        !forceRefresh &&
        _clock().difference(cached.fetchedAt) <= fullSetFreshFor) {
      return Right(cached.page);
    }
    final result = await _fetch(request);
    return result.map((model) {
      final page = model.toEntity();
      _rememberFullSet(key, page);
      return page;
    });
  }

  Future<Either<Failure, T>> _fetch<T>(Future<T> Function() request) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await request());
    } on Exception catch (error) {
      return Left(failureFromException(error));
    }
  }

  void _rememberFullSet(String key, PropertiesPageEntity page) {
    _fullSets
      ..remove(key)
      ..[key] = _FullSet(page, _clock());
    while (_fullSets.length > fullSetMemoryLimit) {
      _fullSets.remove(_fullSets.keys.first);
    }
  }

  void _rememberDetails(PropertyEntity property) {
    _details
      ..remove(property.id)
      ..[property.id] = property;
    if (_details.length > detailsMemoryLimit) {
      _details.remove(_details.keys.first);
    }
  }
}

class _FullSet {
  const _FullSet(this.page, this.fetchedAt);

  final PropertiesPageEntity page;
  final DateTime fetchedAt;
}
