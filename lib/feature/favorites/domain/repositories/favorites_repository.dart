import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Favorites kept on the device only (Q8). They don't need the API, so they
/// work offline and survive restarts.
abstract interface class FavoritesRepository {
  /// Newest first. An empty list when nothing was saved yet.
  Future<Either<Failure, List<PropertyEntity>>> getFavorites();

  /// Replaces the saved list.
  Future<Either<Failure, Unit>> saveFavorites(List<PropertyEntity> favorites);
}
