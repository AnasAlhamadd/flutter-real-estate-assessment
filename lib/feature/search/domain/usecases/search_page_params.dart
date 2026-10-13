import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_query.dart';

/// Parameters of the paged search use cases. [query] is normalized here, so
/// every caller hits the same cache entry.
class SearchPageParams extends Equatable {
  SearchPageParams({required String query, this.cancellation})
    : query = SearchQuery.normalize(query);

  final String query;
  final CancellationSignal? cancellation;

  @override
  List<Object?> get props => [query, cancellation];
}
