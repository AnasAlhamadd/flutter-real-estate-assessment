import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/exception_failure_mapper.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/network/network_info.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/datasource/properties_remote_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  PropertiesRepositoryImpl({required this._remote, required this._networkInfo});

  static const int detailsMemoryLimit = 20;

  final PropertiesRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  /// Insertion-ordered, so the first key is the least recently stored.
  final LinkedHashMap<int, PropertyEntity> _details = LinkedHashMap();

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

  void _rememberDetails(PropertyEntity property) {
    _details
      ..remove(property.id)
      ..[property.id] = property;
    if (_details.length > detailsMemoryLimit) {
      _details.remove(_details.keys.first);
    }
  }
}
