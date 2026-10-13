import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';

class GetRecommendationsUseCase
    implements UseCase<PropertiesPageEntity, RecommendationsParams> {
  const GetRecommendationsUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, PropertiesPageEntity>> call(
    RecommendationsParams params,
  ) => _repository.getRecommendations(
    categorySlug: params.categorySlug,
    page: params.page,
  );
}

class RecommendationsParams extends Equatable {
  /// A `null` [categorySlug] means "All".
  const RecommendationsParams({this.categorySlug, required this.page})
    : assert(page >= 0);

  final String? categorySlug;
  final int page;

  @override
  List<Object?> get props => [categorySlug, page];
}
