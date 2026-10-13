import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';

/// Paged search with a session cache keyed by the normalized query. Every
/// method expects an already normalized query (`SearchQuery.normalize`).
abstract interface class SearchRepository {
  /// Every cached page for [query], or `null`. Memory only: no request, and
  /// it works offline.
  SearchResultsEntity? cachedResults(String query);

  /// The cached pages for [query], or its first page from the API.
  Future<Either<Failure, SearchResultsEntity>> searchFirstPage(
    String query, {
    CancellationSignal? cancellation,
  });

  /// Fetches the first page that isn't cached yet and returns every page.
  /// Nothing is requested once the last page is loaded.
  Future<Either<Failure, SearchResultsEntity>> loadNextPage(
    String query, {
    CancellationSignal? cancellation,
  });

  /// Fetches the already loaded range again in one request and replaces the
  /// cached pages. A failure leaves the cache as it was.
  Future<Either<Failure, SearchResultsEntity>> refreshResults(
    String query, {
    CancellationSignal? cancellation,
  });
}
