import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exception_failure_mapper.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  PropertiesRepositoryImpl({
    required this._remote,
    required this._local,
    required this._networkInfo,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const Duration firstPageMaxAge = Duration(hours: 24);
  static const Duration categoriesMaxAge = Duration(hours: 24);
  static const int detailsMemoryLimit = 20;

  final PropertiesRemoteDataSource _remote;
  final PropertiesLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final DateTime Function() _clock;

  List<CategoryEntity>? _categories;

  /// Insertion-ordered, so the first key is the least recently stored.
  final LinkedHashMap<int, PropertyEntity> _details = LinkedHashMap();

  @override
  Future<Either<Failure, PropertiesPageEntity>> getProperties({
    required int page,
  }) async {
    final result = await _fetch(
      () => _remote.getProducts(
        limit: ApiConstants.pageSize,
        skip: page * ApiConstants.pageSize,
      ),
    );
    if (page != 0) return result.map((model) => model.toEntity());
    return result.fold<Future<Either<Failure, PropertiesPageEntity>>>(
      _firstPageFallback,
      (model) async {
        await _bestEffort(() => _local.cacheFirstPage(model));
        return Right(model.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, PropertiesPageEntity>> getPropertiesByCategory({
    required String categorySlug,
    required int page,
  }) async => (await _fetch(
    () => _remote.getProductsByCategory(
      categorySlug,
      limit: ApiConstants.pageSize,
      skip: page * ApiConstants.pageSize,
    ),
  )).map((model) => model.toEntity());

  @override
  Future<Either<Failure, PropertiesPageEntity>> searchProperties({
    required String query,
    CancellationSignal? cancellation,
  }) async => (await _fetch(
    () => _remote.searchProducts(query, cancellation: cancellation),
  )).map((model) => model.toEntity());

  @override
  Future<Either<Failure, PropertiesPageEntity>> getAllProperties({
    CancellationSignal? cancellation,
  }) async => (await _fetch(
    () => _remote.getAllProducts(cancellation: cancellation),
  )).map((model) => model.toEntity());

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties({
    required int limit,
  }) async => (await _fetch(
    () => _remote.getFeaturedProducts(limit: limit),
  )).map((model) => model.toEntity().items);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (_categories case final categories?) return Right(categories);

    final stored = await _readOrNull(_local.getCategories);
    if (stored != null && _isFresh(stored.cachedAt, categoriesMaxAge)) {
      return Right(_rememberCategories(stored.data));
    }

    final result = await _fetch(_remote.getCategories);
    return result.fold<Future<Either<Failure, List<CategoryEntity>>>>(
      (failure) async => stored == null
          ? Left(failure)
          : Right(_rememberCategories(stored.data)),
      (models) async {
        await _bestEffort(() => _local.cacheCategories(models));
        return Right(_rememberCategories(models));
      },
    );
  }

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

  Future<Either<Failure, T>> _fetch<T>(Future<T> Function() request) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await request());
    } on Exception catch (error) {
      return Left(failureFromException(error));
    }
  }

  Future<Either<Failure, PropertiesPageEntity>> _firstPageFallback(
    Failure failure,
  ) async {
    final canFallBack = switch (failure) {
      NetworkFailure() ||
      TimeoutFailure() ||
      ServerFailure() ||
      UnexpectedResponseFailure() => true,
      _ => false,
    };
    if (!canFallBack) return Left(failure);
    final stored = await _readOrNull(_local.getFirstPage);
    if (stored == null || !_isFresh(stored.cachedAt, firstPageMaxAge)) {
      return Left(failure);
    }
    return Right(
      stored.data.toEntity(isFromCache: true, cachedAt: stored.cachedAt),
    );
  }

  /// A timestamp in the future (device clock changed) is treated as stale.
  bool _isFresh(DateTime cachedAt, Duration maxAge) {
    final age = _clock().difference(cachedAt);
    return !age.isNegative && age < maxAge;
  }

  Future<CachedEntry<T>?> _readOrNull<T>(
    Future<CachedEntry<T>> Function() read,
  ) async {
    try {
      return await read();
    } on CacheException {
      return null;
    }
  }

  /// Cache writes never fail the user's request.
  Future<void> _bestEffort(Future<void> Function() write) async {
    try {
      await write();
    } on Exception {
      return;
    }
  }

  List<CategoryEntity> _rememberCategories(List<CategoryModel> models) =>
      _categories = models
          .map((model) => model.toEntity())
          .toList(growable: false);

  void _rememberDetails(PropertyEntity property) {
    _details
      ..remove(property.id)
      ..[property.id] = property;
    if (_details.length > detailsMemoryLimit) {
      _details.remove(_details.keys.first);
    }
  }
}
