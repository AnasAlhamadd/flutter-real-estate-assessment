import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_query.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/repositories/search_repository.dart';

/// Synchronous on purpose: a memory read can't fail, and the cubit shows a
/// cache hit in the same frame instead of flashing a loading state.
class GetCachedSearchResultsUseCase {
  const GetCachedSearchResultsUseCase(this._repository);

  final SearchRepository _repository;

  SearchResultsEntity? call(String query) =>
      _repository.cachedResults(SearchQuery.normalize(query));
}
