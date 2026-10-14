import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/enums/data_source.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_home_repository.dart';
import '../../../../helpers/fake_search_repository.dart';

void main() {
  late FakeSearchRepository search;
  late FakeHomeRepository home;
  late SearchCubit cubit;
  late List<SearchState> emitted;

  setUp(() async {
    search = FakeSearchRepository();
    home = FakeHomeRepository();
    cubit = searchCubitFor(search, home);
    await cubit.load();
    emitted = [];
    final subscription = cubit.stream.listen(emitted.add);
    addTearDown(subscription.cancel);
  });

  tearDown(() => cubit.close());

  test('pull to refresh shows loading with the results kept, then the new '
      'results', () async {
    final before = cubit.state.items;

    await cubit.refresh();

    expect(emitted.first.status, RequestStatus.loading);
    expect(emitted.first.items, before);
    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.isRefreshing, isFalse);
    expect(cubit.state.refreshFailed, isFalse);
  });

  test('a failed pull to refresh brings the results back', () async {
    final before = cubit.state.items;
    home.firstPage = const Left(NetworkFailure());

    await cubit.refresh();

    expect(cubit.state.status, RequestStatus.success);
    expect(cubit.state.items, before);
    expect(cubit.state.refreshFailed, isTrue);
  });

  test('a saved copy counts as a failed refresh', () async {
    home.firstPage = Right(pageOf(sampleProperties, isFromCache: true));

    await cubit.refresh();

    expect(cubit.state.source, DataSource.remote);
    expect(cubit.state.refreshFailed, isTrue);
  });

  test('saved browse results block paging until a refresh succeeds', () async {
    home.firstPage = Right(
      pageOf(sampleProperties, hasReachedMax: false, isFromCache: true),
    );
    final saved = searchCubitFor(search, home);
    addTearDown(saved.close);
    await saved.load();

    expect(saved.state.source, DataSource.saved);
    expect(saved.state.canLoadMore, isFalse);

    home.firstPage = Right(pageOf(sampleProperties, hasReachedMax: false));
    await saved.refresh();

    expect(saved.state.source, DataSource.remote);
    expect(saved.state.canLoadMore, isTrue);
  });

  test('a stale cached query refreshes without a loading status', () async {
    search.cached = {
      'mirror': SearchResultsEntity(
        query: 'mirror',
        items: [sampleProperties[3]],
        total: 1,
        hasReachedMax: true,
        isStale: true,
      ),
    };

    await cubit.submitQuery('mirror');
    await pumpEventQueue();

    expect(search.requests, ['refresh:mirror']);
    expect(
      emitted
          .where((state) => state.mode == SearchMode.search)
          .map((state) => state.status),
      everyElement(RequestStatus.success),
    );
  });
}
