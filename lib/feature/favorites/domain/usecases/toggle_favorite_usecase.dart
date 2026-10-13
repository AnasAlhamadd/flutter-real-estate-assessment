import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Adds or removes a property, matched by [PropertyEntity.id] so the same
/// property from different lists is one favorite.
///
/// Synchronous and pure: the caller shows the result immediately and saves
/// it separately.
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase();

  /// Bounds the saved list (reference §4.5.2).
  static const int maxFavorites = 100;

  Either<Failure, List<PropertyEntity>> call(ToggleFavoriteParams params) {
    final id = params.property.id;
    final current = params.favorites;
    if (current.any((favorite) => favorite.id == id)) {
      return Right(
        current.where((favorite) => favorite.id != id).toList(growable: false),
      );
    }
    if (current.length >= maxFavorites) {
      return const Left(FavoritesLimitFailure());
    }
    return Right(List.unmodifiable([params.property, ...current]));
  }
}

class ToggleFavoriteParams extends Equatable {
  const ToggleFavoriteParams({required this.favorites, required this.property});

  /// Newest first, unique ids.
  final List<PropertyEntity> favorites;
  final PropertyEntity property;

  @override
  List<Object?> get props => [favorites, property];
}
