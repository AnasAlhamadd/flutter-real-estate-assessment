import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/repositories/property_extras_repository.dart';

class GetPropertyExtrasUseCase
    implements UseCase<PropertyExtrasEntity, PropertyDetailsParams> {
  const GetPropertyExtrasUseCase(this._repository);

  final PropertyExtrasRepository _repository;

  @override
  Future<Either<Failure, PropertyExtrasEntity>> call(
    PropertyDetailsParams params,
  ) => _repository.getPropertyExtras(params.id);
}
