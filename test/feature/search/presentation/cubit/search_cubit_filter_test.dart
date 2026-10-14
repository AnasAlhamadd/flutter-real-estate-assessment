import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_home_repository.dart';
import '../../../../helpers/fake_properties_repository.dart';
import '../../../../helpers/fake_search_repository.dart';

const _furniture = PropertyFilter(categorySlugs: {'furniture'});

void main() {
  late FakeSearchRepository search;
  late FakeHomeRepository home;
  late FakePropertiesRepository properties;
  late SearchCubit cubit;

  setUp(() async {
    search = FakeSearchRepository();
    home = FakeHomeRepository();
    properties = FakePropertiesRepository();
    cubit = searchCubitFor(search, home, properties: properties);
    await cubit.load();
  });

  tearDown(() => cubit.close());

  List<int> shownIds() => cubit.state.items.map((item) => item.id).toList();

  test('a filter without a query narrows the whole catalog', () async {
    await cubit.applyFilter(_furniture);

    expect(properties.fullSetRequests, ['']);
    expect(cubit.state.mode, SearchMode.filtered);
    expect(cubit.state.filter, _furniture);
    expect(shownIds(), [3, 4]);
    expect(cubit.state.total, 2);
    expect(cubit.state.canLoadMore, isFalse);
  });

  test('categories and prices combine', () async {
    await cubit.applyFilter(
      const PropertyFilter(
        categorySlugs: {'beauty', 'fragrances'},
        priceRange: PriceRange(min: 15, max: double.infinity),
      ),
    );

    expect(shownIds(), [2, 5]);
  });

  test('applying the same filter again sends nothing', () async {
    await cubit.applyFilter(_furniture);
    await cubit.applyFilter(const PropertyFilter(categorySlugs: {'furniture'}));

    expect(properties.fullSetRequests, ['']);
  });

  test('a query while filtered loads its full set, not search pages', () async {
    await cubit.applyFilter(_furniture);
    await cubit.submitQuery('mirror');

    expect(properties.fullSetRequests, ['', 'mirror']);
    expect(search.requests, isEmpty);
    expect(cubit.state.query, 'mirror');
    expect(shownIds(), [4]);
  });

  test('a filter on a search narrows that search', () async {
    await cubit.submitQuery('mirror');
    await cubit.applyFilter(_furniture);

    expect(properties.fullSetRequests, ['mirror']);
    expect(shownIds(), [4]);
  });

  test('clearing the filter returns to paged search', () async {
    await cubit.submitQuery('mirror');
    await cubit.applyFilter(_furniture);
    await cubit.applyFilter(PropertyFilter.none);

    expect(cubit.state.mode, SearchMode.search);
    expect(cubit.state.filter, PropertyFilter.none);
    expect(shownIds(), [2, 4]);
  });

  test('clearing the filter without a query restores the "All" listing '
      'without a request', () async {
    await cubit.applyFilter(_furniture);
    await cubit.applyFilter(PropertyFilter.none);

    expect(cubit.state.mode, SearchMode.browse);
    expect(shownIds(), [1, 2, 3, 4, 5]);
    expect(home.pageRequests, ['all:0']);
  });

  test('nothing passing the filter is an empty filtered state', () async {
    await cubit.submitQuery('mirror');
    await cubit.applyFilter(
      const PropertyFilter(categorySlugs: {'fragrances'}),
    );

    expect(cubit.state.mode, SearchMode.filtered);
    expect(cubit.state.status, RequestStatus.empty);
  });

  test('a failed full set can be retried', () async {
    properties.fullSets = {'': const Left(NetworkFailure())};
    await cubit.applyFilter(_furniture);

    expect(cubit.state.status, RequestStatus.failure);
    expect(cubit.state.mode, SearchMode.filtered);

    properties.fullSets = {};
    await cubit.retry();

    expect(properties.fullSetRequests, ['', '']);
    expect(shownIds(), [3, 4]);
  });

  test('pull to refresh skips the in-memory copy', () async {
    await cubit.applyFilter(_furniture);
    await cubit.refresh();

    expect(properties.fullSetRequests, ['', ':refresh']);
    expect(cubit.state.isRefreshing, isFalse);
    expect(shownIds(), [3, 4]);
  });
}
