import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';

abstract interface class PropertyExtrasRepository {
  Future<Either<Failure, PropertyExtrasEntity>> getPropertyExtras(
    int propertyId,
  );
}
