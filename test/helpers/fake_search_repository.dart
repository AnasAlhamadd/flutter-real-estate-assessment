import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/search_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/repositories/search_repository.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/get_cached_search_results_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/load_more_search_results_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/refresh_search_results_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/usecases/search_first_page_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_cubit.dart';

import 'fake_properties_repository.dart';
import 'sample_properties.dart';

/// In-memory [SearchRepository] for widget tests. A query's first page is
/// [firstPages]`[query]`, or the sample items whose title contains it. Next
/// pages come from [nextPages]; a missing one ends the results. Nothing is
/// cached unless [cached] has it. [gate] holds every response.
class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository({
    this.firstPages = const {},
    this.nextPages = const {},
    this.cached = const {},
  });

  Map<String, Either<Failure, SearchResultsEntity>> firstPages;
  Map<String, Either<Failure, SearchResultsEntity>> nextPages;
  Map<String, SearchResultsEntity> cached;

  Future<void>? gate;

  /// Holds only next-page requests.
  Future<void>? nextPageGate;

  /// Every remote request, as `first:<query>`, `next:<query>` or
  /// `refresh:<query>`.
  final List<String> requests = [];

  @override
  SearchResultsEntity? cachedResults(String query) => cached[query];

  @override
  Future<Either<Failure, SearchResultsEntity>> searchFirstPage(
    String query, {
    CancellationSignal? cancellation,
  }) async {
    requests.add('first:$query');
    await gate;
    return firstPages[query] ?? Right(_matching(query));
  }

  @override
  Future<Either<Failure, SearchResultsEntity>> loadNextPage(
    String query, {
    CancellationSignal? cancellation,
  }) async {
    requests.add('next:$query');
    await gate;
    await nextPageGate;
    return nextPages[query] ?? Right(_matching(query));
  }

  @override
  Future<Either<Failure, SearchResultsEntity>> refreshResults(
    String query, {
    CancellationSignal? cancellation,
  }) async {
    requests.add('refresh:$query');
    await gate;
    return firstPages[query] ?? Right(_matching(query));
  }

  static SearchResultsEntity _matching(String query) {
    final items = sampleProperties
        .where((item) => item.title.toLowerCase().contains(query))
        .toList();
    return SearchResultsEntity(
      query: query,
      items: items,
      total: items.length,
      hasReachedMax: true,
    );
  }
}

/// A real [SearchCubit] over [search] (results), [home] (the browse listing
/// and categories) and [properties] (full sets while filtered; sample
/// matches by default), with the app's debounce.
SearchCubit searchCubitFor(
  SearchRepository search,
  HomeRepository home, {
  PropertiesRepository? properties,
  Duration debounce = SearchCubit.defaultDebounce,
}) => SearchCubit(
  getCachedResults: GetCachedSearchResultsUseCase(search),
  searchFirstPage: SearchFirstPageUseCase(search),
  loadMoreResults: LoadMoreSearchResultsUseCase(search),
  refreshResults: RefreshSearchResultsUseCase(search),
  getBrowsePage: GetRecommendationsUseCase(home),
  getCategories: GetCategoriesUseCase(home),
  getAllMatches: SearchPropertiesUseCase(
    properties ?? FakePropertiesRepository(),
  ),
  debounce: debounce,
);

/// A real [FilterCubit] over [properties] (full sets) and [home]
/// (categories).
FilterCubit filterCubitFor(
  PropertiesRepository properties,
  HomeRepository home,
) => FilterCubit(
  getAllMatches: SearchPropertiesUseCase(properties),
  getCategories: GetCategoriesUseCase(home),
);
