import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/repositories/search_repository.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/search_page_params.dart';

class RefreshSearchResultsUseCase
    implements UseCase<SearchResultsEntity, SearchPageParams> {
  const RefreshSearchResultsUseCase(this._repository);

  final SearchRepository _repository;

  @override
  Future<Either<Failure, SearchResultsEntity>> call(SearchPageParams params) =>
      _repository.refreshResults(
        params.query,
        cancellation: params.cancellation,
      );
}
