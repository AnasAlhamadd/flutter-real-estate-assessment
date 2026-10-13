import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class SaveFavoritesUseCase implements UseCase<Unit, SaveFavoritesParams> {
  const SaveFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveFavoritesParams params) =>
      _repository.saveFavorites(params.favorites);
}

class SaveFavoritesParams extends Equatable {
  const SaveFavoritesParams(this.favorites);

  final List<PropertyEntity> favorites;

  @override
  List<Object?> get props => [favorites];
}
