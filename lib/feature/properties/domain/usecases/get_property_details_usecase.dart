import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

class GetPropertyDetailsUseCase
    implements UseCase<PropertyEntity, PropertyDetailsParams> {
  const GetPropertyDetailsUseCase(this._repository);

  final PropertiesRepository _repository;

  @override
  Future<Either<Failure, PropertyEntity>> call(PropertyDetailsParams params) =>
      _repository.getPropertyDetails(params.id);
}

class PropertyDetailsParams extends Equatable {
  const PropertyDetailsParams({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
