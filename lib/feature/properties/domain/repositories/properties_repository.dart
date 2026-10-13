import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

abstract interface class PropertiesRepository {
  /// Full matching set for a non-empty search text. Remote only.
  Future<Either<Failure, PropertiesPageEntity>> searchProperties({
    required String query,
    CancellationSignal? cancellation,
  });

  /// The whole catalog, used when only a price filter is active. Remote only.
  Future<Either<Failure, PropertiesPageEntity>> getAllProperties({
    CancellationSignal? cancellation,
  });

  /// Full product. Kept in memory for the session, never persisted.
  Future<Either<Failure, PropertyEntity>> getPropertyDetails(int id);
}
