import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class GetFavoritesUseCase implements UseCase<List<PropertyEntity>, NoParams> {
  const GetFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(NoParams params) =>
      _repository.getFavorites();
}
