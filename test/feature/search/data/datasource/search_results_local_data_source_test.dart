import 'package:flutter_real_estate_assessment/feature/search/data/datasource/search_results_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

final _fetchedAt = DateTime.utc(2026, 10, 14, 9);

SearchCacheEntry _entry({int total = 1, DateTime? fetchedAt}) =>
    SearchCacheEntry(
      items: const [],
      total: total,
      nextSkip: 20,
      hasReachedMax: false,
      fetchedAt: fetchedAt ?? _fetchedAt,
    );

void main() {
  late SearchResultsMemoryDataSource source;

  setUp(() => source = SearchResultsMemoryDataSource(maxQueries: 2));

  test('returns null for a query that was never written', () {
    expect(source.read('phone'), isNull);
  });

  test('returns the written entry', () {
    source.write('phone', _entry(total: 5));

    expect(source.read('phone'), _entry(total: 5));
  });

  test('a new write replaces the entry of the same query', () {
    source
      ..write('phone', _entry(total: 5))
      ..write('phone', _entry(total: 7));

    expect(source.read('phone'), _entry(total: 7));
  });

  test('evicts the least recently written query beyond the bound', () {
    source
      ..write('a', _entry())
      ..write('b', _entry())
      ..write('c', _entry());

    expect(source.read('a'), isNull);
    expect(source.read('b'), isNotNull);
    expect(source.read('c'), isNotNull);
  });

  test('reading a query keeps it from being evicted next', () {
    source
      ..write('a', _entry())
      ..write('b', _entry());
    source.read('a');
    source.write('c', _entry());

    expect(source.read('a'), isNotNull);
    expect(source.read('b'), isNull);
  });

  group('isStale', () {
    test('is fresh up to the freshness window', () {
      final now = _fetchedAt.add(SearchResultsMemoryDataSource.defaultFreshFor);

      expect(source.isStale(_entry(), now), isFalse);
    });

    test('is stale once the window has passed', () {
      final now = _fetchedAt.add(
        SearchResultsMemoryDataSource.defaultFreshFor +
            const Duration(seconds: 1),
      );

      expect(source.isStale(_entry(), now), isTrue);
    });
  });
}
