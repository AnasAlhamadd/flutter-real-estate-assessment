import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/repositories/property_extras_repository.dart';

class PropertyExtrasRepositoryImpl implements PropertyExtrasRepository {
  const PropertyExtrasRepositoryImpl({required this._mockDataSource});

  /// this mock: the only source until an API provides these fields.
  final PropertyExtrasMockDataSource _mockDataSource;

  @override
  Future<Either<Failure, PropertyExtrasEntity>> getPropertyExtras(
    int propertyId,
  ) async {
    try {
      return Right(await _mockDataSource.getPropertyExtras(propertyId));
    } on Object {
      return const Left(UnknownFailure());
    }
  }
}
