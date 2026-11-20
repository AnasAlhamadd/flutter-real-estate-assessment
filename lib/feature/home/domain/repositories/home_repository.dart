import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

abstract interface class HomeRepository {
  /// Highest-rated products for the "Featured" section. Remote only.
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties({
    required int limit,
  });

  /// Memory, then a saved copy under 24 h old, then the API. Falls back to a
  /// saved copy of any age when the API fails.
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// One page of recommendations: "All" when [categorySlug] is `null`,
  /// otherwise that category. The "All" first page falls back to its saved
  /// copy (under 24 h old) on any failure except cancellation.
  Future<Either<Failure, PropertiesPageEntity>> getRecommendations({
    String? categorySlug,
    required int page,
  });
}
