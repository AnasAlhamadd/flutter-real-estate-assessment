import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

/// Loads the full matching set for full-set mode.
///
/// A blank query (only a price filter active) loads the whole catalog.
/// The API is English-only, so Arabic text returns an empty result.
class SearchPropertiesUseCase
    implements UseCase<PropertiesPageEntity, SearchParams> {
  const SearchPropertiesUseCase(this._repository);

  final PropertiesRepository _repository;

  @override
  Future<Either<Failure, PropertiesPageEntity>> call(SearchParams params) {
    final query = params.query.trim();
    if (query.isEmpty) {
      return _repository.getAllProperties(cancellation: params.cancellation);
    }
    return _repository.searchProperties(
      query: query,
      cancellation: params.cancellation,
    );
  }
}

class SearchParams extends Equatable {
  const SearchParams({required this.query, this.cancellation});

  final String query;
  final CancellationSignal? cancellation;

  @override
  List<Object?> get props => [query, cancellation];
}
