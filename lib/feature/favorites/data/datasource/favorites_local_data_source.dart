import 'package:flutter_real_estate_assessment/core/constant/storage_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/storage/versioned_preferences_store.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favorites under [StorageKeys.favorites]: listing-field snapshots, newest
/// first (reference §4.5.2).
abstract interface class FavoritesLocalDataSource {
  /// Empty when nothing was saved. Throws [CacheException] when the saved
  /// value is unreadable (it is removed).
  Future<List<PropertyModel>> getFavorites();

  /// Throws [CacheException] when the list can't be saved.
  Future<void> saveFavorites(List<PropertyModel> favorites);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(
    SharedPreferences preferences, {
    DateTime Function()? clock,
  }) : _store = VersionedPreferencesStore(
         preferences,
         schemaVersion: schemaVersion,
         clock: clock,
       );

  /// Bump when the stored JSON shape changes; older entries are then dropped.
  static const int schemaVersion = 1;

  /// 100 listing snapshots measure well under this.
  static const int maxEntryBytes = 64 * 1024;

  final VersionedPreferencesStore _store;

  @override
  Future<List<PropertyModel>> getFavorites() async {
    if (!_store.contains(StorageKeys.favorites)) return const [];
    final entry = await _store.read(StorageKeys.favorites, _parse);
    return entry.data;
  }

  @override
  Future<void> saveFavorites(List<PropertyModel> favorites) async {
    final saved = await _store.write(
      StorageKeys.favorites,
      favorites.map((favorite) => favorite.toJson()).toList(),
      maxBytes: maxEntryBytes,
    );
    if (!saved) throw const CacheException();
  }

  /// Skips entries without a valid id and repeated ids.
  static List<PropertyModel> _parse(Object? data) {
    if (data is! List) throw const FormatException('Favorites are not a list');
    final ids = <int>{};
    final favorites = <PropertyModel>[];
    for (final item in data.whereType<Map<String, dynamic>>()) {
      try {
        final favorite = PropertyModel.fromJson(item);
        if (ids.add(favorite.id)) favorites.add(favorite);
      } on FormatException {
        continue;
      }
    }
    return List.unmodifiable(favorites);
  }
}
