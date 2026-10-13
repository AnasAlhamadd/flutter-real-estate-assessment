import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFavorites() async {
    try {
      final favorites = await _local.getFavorites();
      return Right(
        favorites
            .map((favorite) => favorite.toEntity())
            .toList(growable: false),
      );
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveFavorites(
    List<PropertyEntity> favorites,
  ) async {
    try {
      await _local.saveFavorites(
        favorites.map(PropertyModel.listingFromEntity).toList(growable: false),
      );
      return const Right(unit);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
