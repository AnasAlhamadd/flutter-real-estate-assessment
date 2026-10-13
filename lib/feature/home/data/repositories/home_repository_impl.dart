import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/error/exception_failure_mapper.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required this._remote,
    required this._local,
    required this._networkInfo,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const Duration firstPageMaxAge = Duration(hours: 24);
  static const Duration categoriesMaxAge = Duration(hours: 24);

  final HomeRemoteDataSource _remote;
  final HomeLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final DateTime Function() _clock;

  List<CategoryEntity>? _categories;

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
  Future<Either<Failure, PropertiesPageEntity>> getRecommendations({
    String? categorySlug,
    required int page,
  }) async {
    final skip = page * ApiConstants.pageSize;
    if (categorySlug != null) {
      return (await _fetch(
        () => _remote.getProductsByCategory(
          categorySlug,
          limit: ApiConstants.pageSize,
          skip: skip,
        ),
      )).map((model) => model.toEntity());
    }

    final result = await _fetch(
      () => _remote.getProducts(limit: ApiConstants.pageSize, skip: skip),
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

  Future<Either<Failure, T>> _fetch<T>(Future<T> Function() request) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await request());
    } on Exception catch (error) {
      return Left(failureFromException(error));
    }
  }

  /// Any failure except a cancellation serves the saved copy, when one under
  /// [firstPageMaxAge] exists.
  Future<Either<Failure, PropertiesPageEntity>> _firstPageFallback(
    Failure failure,
  ) async {
    if (failure is CancelledFailure) return Left(failure);
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
}
