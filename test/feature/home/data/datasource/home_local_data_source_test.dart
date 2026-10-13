import 'dart:convert';

import 'package:flutter_real_estate_assessment/core/constant/storage_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/feature/home/data/datasource/home_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../../helpers/mocks.dart';

void main() {
  final now = DateTime.utc(2026, 10, 13, 12);
  late SharedPreferences preferences;
  late HomeLocalDataSourceImpl dataSource;

  Future<void> createWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    preferences = await SharedPreferences.getInstance();
    dataSource = HomeLocalDataSourceImpl(preferences, clock: () => now);
  }

  setUp(() => createWith({}));

  PropertiesResponseModel page(String name) =>
      PropertiesResponseModel.fromJson(fixtureMap(name));

  String envelope({required Object? data, Object? version = 1}) => jsonEncode({
    'schemaVersion': version,
    'cachedAt': now.toIso8601String(),
    'data': data,
  });

  group('first page', () {
    test('round-trips the page with its timestamp', () async {
      final original = page('products_page.json');

      await dataSource.cacheFirstPage(original);
      final cached = await dataSource.getFirstPage();

      expect(cached.cachedAt, now);
      expect(cached.data.toEntity(), original.toEntity());
    });

    test('stores a versioned envelope with a UTC timestamp', () async {
      await dataSource.cacheFirstPage(page('products_page.json'));

      final stored =
          jsonDecode(preferences.getString(StorageKeys.productsFirstPage)!)
              as Map<String, dynamic>;

      expect(stored['schemaVersion'], 1);
      expect(stored['cachedAt'], '2026-10-13T12:00:00.000Z');
      expect(stored['data'], isA<Map<String, dynamic>>());
    });

    test('throws CacheException when nothing is stored', () {
      expect(dataSource.getFirstPage(), throwsA(const CacheException()));
    });

    test('skips pages with more items than one page', () async {
      await dataSource.cacheFirstPage(page('search_results.json'));

      expect(preferences.containsKey(StorageKeys.productsFirstPage), isFalse);
    });

    test('throws CacheException when the page cannot be encoded', () async {
      const unencodable = PropertiesResponseModel(
        products: [
          PropertyModel(
            id: 1,
            title: 'Odd',
            price: double.nan,
            rating: 0,
            category: 'beauty',
          ),
        ],
        total: 1,
        skip: 0,
        limit: 1,
      );

      await expectLater(
        dataSource.cacheFirstPage(unencodable),
        throwsA(const CacheException()),
      );
      expect(preferences.containsKey(StorageKeys.productsFirstPage), isFalse);
    });
  });

  group('categories', () {
    test('round-trips the list with its timestamp', () async {
      final original = CategoryModel.listFromJson(
        fixtureList('categories.json'),
      );

      await dataSource.cacheCategories(original);
      final cached = await dataSource.getCategories();

      expect(cached.cachedAt, now);
      expect(
        cached.data.map((category) => category.toJson()),
        original.map((category) => category.toJson()),
      );
    });

    test('skips writes larger than the size bound', () async {
      final huge = List.generate(
        2000,
        (index) => CategoryModel(slug: 'slug-$index', name: 'Name $index'),
      );

      await dataSource.cacheCategories(huge);

      expect(preferences.containsKey(StorageKeys.categories), isFalse);
    });
  });

  group('unusable entries are removed and reported as CacheException', () {
    final cases = <String, Object>{
      'an older schema version': envelope(data: const [], version: 0),
      'invalid JSON': '{not json',
      'a missing timestamp': jsonEncode({'schemaVersion': 1, 'data': []}),
      'an invalid timestamp': jsonEncode({
        'schemaVersion': 1,
        'cachedAt': 'yesterday',
        'data': [],
      }),
      'data of the wrong shape': envelope(data: const {'slug': 'beauty'}),
      'a non-string value': 42,
    };

    cases.forEach((description, stored) {
      test(description, () async {
        await createWith({StorageKeys.categories: stored});

        await expectLater(
          dataSource.getCategories(),
          throwsA(const CacheException()),
        );
        expect(preferences.containsKey(StorageKeys.categories), isFalse);
      });
    });

    test('a first page whose products are not a list', () async {
      await createWith({
        StorageKeys.productsFirstPage: envelope(
          data: fixtureMap('products_not_a_list.json'),
        ),
      });

      await expectLater(
        dataSource.getFirstPage(),
        throwsA(const CacheException()),
      );
      expect(preferences.containsKey(StorageKeys.productsFirstPage), isFalse);
    });
  });

  test('writes only the two approved keys', () async {
    await createWith({'locale': 'ar'});

    await dataSource.cacheFirstPage(page('products_page.json'));
    await dataSource.cacheCategories(
      CategoryModel.listFromJson(fixtureList('categories.json')),
    );

    expect(preferences.getKeys(), {
      'locale',
      StorageKeys.productsFirstPage,
      StorageKeys.categories,
    });
  });

  test('throws CacheException when the platform rejects the write', () {
    final rejecting = MockSharedPreferences();
    when(
      () => rejecting.setString(any(), any()),
    ).thenAnswer((_) async => false);

    expect(
      HomeLocalDataSourceImpl(
        rejecting,
      ).cacheCategories(const [CategoryModel(slug: 'beauty', name: 'Beauty')]),
      throwsA(const CacheException()),
    );
  });
}
