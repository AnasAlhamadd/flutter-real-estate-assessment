import 'dart:convert';

import 'package:flutter_real_estate_assessment/core/constant/storage_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime.utc(2026, 10, 13, 12);
  late SharedPreferences preferences;
  late FavoritesLocalDataSourceImpl dataSource;

  Future<void> createWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    preferences = await SharedPreferences.getInstance();
    dataSource = FavoritesLocalDataSourceImpl(preferences, clock: () => now);
  }

  setUp(() => createWith({}));

  PropertyModel model(int id) => PropertyModel(
    id: id,
    title: 'Home $id',
    price: 100.5 + id,
    rating: 4.5,
    category: 'furniture',
    brand: id.isEven ? 'Brand $id' : null,
    thumbnailUrl: 'https://cdn.dummyjson.com/$id/thumbnail.webp',
  );

  List<Map<String, dynamic>> json(List<PropertyModel> favorites) =>
      favorites.map((favorite) => favorite.toJson()).toList();

  String envelope(Object? data, {int version = 1}) => jsonEncode({
    'schemaVersion': version,
    'cachedAt': now.toIso8601String(),
    'data': data,
  });

  test('nothing saved yet is an empty list', () async {
    expect(await dataSource.getFavorites(), isEmpty);
  });

  test('round-trips the list in order', () async {
    final favorites = [model(3), model(1), model(2)];

    await dataSource.saveFavorites(favorites);

    expect(json(await dataSource.getFavorites()), json(favorites));
    final restarted = FavoritesLocalDataSourceImpl(preferences);
    expect(json(await restarted.getFavorites()), json(favorites));
  });

  test('stores the schema version and the time of the save', () async {
    await dataSource.saveFavorites([model(1)]);

    final stored =
        jsonDecode(preferences.getString(StorageKeys.favorites)!)
            as Map<String, dynamic>;
    expect(stored['schemaVersion'], FavoritesLocalDataSourceImpl.schemaVersion);
    expect(stored['cachedAt'], now.toIso8601String());
  });

  test('saving an empty list clears the favorites', () async {
    await dataSource.saveFavorites([model(1)]);
    await dataSource.saveFavorites(const []);

    expect(await dataSource.getFavorites(), isEmpty);
  });

  test('skips invalid items and repeated ids', () async {
    await createWith({
      StorageKeys.favorites: envelope([
        model(1).toJson(),
        {'title': 'no id'},
        'not an object',
        model(1).toJson(),
        model(2).toJson(),
      ]),
    });

    final favorites = await dataSource.getFavorites();

    expect(favorites.map((favorite) => favorite.id), [1, 2]);
  });

  for (final (name, raw) in [
    ('corrupt JSON', '{oops'),
    ('an older schema', envelope(const [], version: 0)),
    ('data that is not a list', envelope({'id': 1})),
  ]) {
    test('$name throws and is removed', () async {
      await createWith({StorageKeys.favorites: raw});

      await expectLater(
        dataSource.getFavorites(),
        throwsA(const CacheException()),
      );
      expect(preferences.containsKey(StorageKeys.favorites), isFalse);
      expect(await dataSource.getFavorites(), isEmpty);
    });
  }

  test('the maximum number of favorites fits in the size limit', () async {
    final favorites = [
      for (var id = 1; id <= 100; id++)
        PropertyModel(
          id: id,
          title: 'A Long Listing Title For Favorite Number $id' * 2,
          price: 123456.78,
          rating: 4.99,
          category: 'home-decoration',
          brand: 'A Long Brand Name $id',
          thumbnailUrl:
              'https://cdn.dummyjson.com/product-images/home-decoration/$id/thumbnail.webp',
        ),
    ];

    await dataSource.saveFavorites(favorites);

    expect(await dataSource.getFavorites(), hasLength(100));
  });

  test('a list over the size limit throws and keeps the old one', () async {
    await dataSource.saveFavorites([model(1)]);
    final huge = [
      PropertyModel(
        id: 2,
        title: 'x' * (FavoritesLocalDataSourceImpl.maxEntryBytes + 1),
        price: 1,
        rating: 1,
        category: 'beauty',
      ),
    ];

    await expectLater(
      dataSource.saveFavorites(huge),
      throwsA(const CacheException()),
    );
    expect(json(await dataSource.getFavorites()), json([model(1)]));
  });
}
