import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

/// Loads the full matching set for full-set mode.
///
/// A blank query (filters without search text) loads the whole catalog.
/// The API is English-only, so Arabic text returns an empty result.
class SearchPropertiesUseCase
    implements UseCase<PropertiesPageEntity, SearchParams> {
  const SearchPropertiesUseCase(this._repository);

  final PropertiesRepository _repository;

  @override
  Future<Either<Failure, PropertiesPageEntity>> call(SearchParams params) {
    final query = params.query.trim();
    if (query.isEmpty) {
      return _repository.getAllProperties(
        cancellation: params.cancellation,
        forceRefresh: params.forceRefresh,
      );
    }
    return _repository.searchProperties(
      query: query,
      cancellation: params.cancellation,
      forceRefresh: params.forceRefresh,
    );
  }
}

class SearchParams extends Equatable {
  const SearchParams({
    required this.query,
    this.cancellation,
    this.forceRefresh = false,
  });

  final String query;
  final CancellationSignal? cancellation;

  /// Skips the in-memory copy (pull to refresh).
  final bool forceRefresh;

  @override
  List<Object?> get props => [query, cancellation, forceRefresh];
}
