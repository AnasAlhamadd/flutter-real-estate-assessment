import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

abstract interface class PropertiesRepository {
  /// Paged "All" listing. Page 0 falls back to the persisted copy on
  /// network, timeout, server, or malformed-response failures.
  Future<Either<Failure, PropertiesPageEntity>> getProperties({
    required int page,
  });

  /// Paged listing for one category. Remote only.
  Future<Either<Failure, PropertiesPageEntity>> getPropertiesByCategory({
    required String categorySlug,
    required int page,
  });

  /// Full matching set for a non-empty search text. Remote only.
  Future<Either<Failure, PropertiesPageEntity>> searchProperties({
    required String query,
    CancellationSignal? cancellation,
  });

  /// The whole catalog, used when only a price filter is active. Remote only.
  Future<Either<Failure, PropertiesPageEntity>> getAllProperties({
    CancellationSignal? cancellation,
  });

  /// Highest-rated products for the Home "Featured" section. Remote only.
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties({
    required int limit,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Full product. Kept in memory for the session, never persisted.
  Future<Either<Failure, PropertyEntity>> getPropertyDetails(int id);
}
