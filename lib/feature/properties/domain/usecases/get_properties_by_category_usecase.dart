import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

class GetPropertiesByCategoryUseCase
    implements UseCase<PropertiesPageEntity, CategoryPageParams> {
  const GetPropertiesByCategoryUseCase(this._repository);

  final PropertiesRepository _repository;

  @override
  Future<Either<Failure, PropertiesPageEntity>> call(
    CategoryPageParams params,
  ) => _repository.getPropertiesByCategory(
    categorySlug: params.categorySlug,
    page: params.page,
  );
}

class CategoryPageParams extends Equatable {
  const CategoryPageParams({required this.categorySlug, required this.page})
    : assert(page >= 0);

  final String categorySlug;
  final int page;

  @override
  List<Object?> get props => [categorySlug, page];
}
