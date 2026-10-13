import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class GetFeaturedPropertiesUseCase
    implements UseCase<List<PropertyEntity>, FeaturedParams> {
  const GetFeaturedPropertiesUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(FeaturedParams params) =>
      _repository.getFeaturedProperties(limit: params.limit);
}

class FeaturedParams extends Equatable {
  const FeaturedParams({required this.limit}) : assert(limit > 0);

  final int limit;

  @override
  List<Object?> get props => [limit];
}
