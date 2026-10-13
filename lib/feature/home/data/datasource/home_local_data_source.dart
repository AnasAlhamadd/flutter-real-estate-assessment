import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/constant/storage_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/storage/versioned_preferences_store.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:flutter_real_estate_assessment/core/storage/versioned_preferences_store.dart'
    show CachedEntry;

/// The approved persisted cache (reference §4.5.2): the "All" first page and
/// the category list, nothing else.
abstract interface class HomeLocalDataSource {
  /// Throws [CacheException] when nothing usable is stored.
  Future<CachedEntry<PropertiesResponseModel>> getFirstPage();

  /// Skips pages over [HomeLocalDataSourceImpl.maxFirstPageItems] items
  /// or [HomeLocalDataSourceImpl.maxEntryBytes]. Throws
  /// [CacheException] when the page can't be encoded or the write fails.
  Future<void> cacheFirstPage(PropertiesResponseModel page);

  /// Throws [CacheException] when nothing usable is stored.
  Future<CachedEntry<List<CategoryModel>>> getCategories();

  /// Throws [CacheException] when the list can't be encoded or the write
  /// fails.
  Future<void> cacheCategories(List<CategoryModel> categories);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  HomeLocalDataSourceImpl(
    SharedPreferences preferences, {
    DateTime Function()? clock,
  }) : _store = VersionedPreferencesStore(
         preferences,
         schemaVersion: schemaVersion,
         clock: clock,
       );

  /// Bump when the stored JSON shape changes; older entries are then dropped.
  static const int schemaVersion = 1;
  static const int maxEntryBytes = 32 * 1024;
  static const int maxFirstPageItems = ApiConstants.pageSize;

  final VersionedPreferencesStore _store;

  @override
  Future<CachedEntry<PropertiesResponseModel>> getFirstPage() =>
      _store.read(StorageKeys.productsFirstPage, (data) {
        if (data is! Map<String, dynamic>) {
          throw const FormatException('Cached page is not an object');
        }
        return PropertiesResponseModel.fromJson(data);
      });

  @override
  Future<void> cacheFirstPage(PropertiesResponseModel page) async {
    if (page.products.length > maxFirstPageItems) return;
    await _store.write(
      StorageKeys.productsFirstPage,
      page.toJson(),
      maxBytes: maxEntryBytes,
    );
  }

  @override
  Future<CachedEntry<List<CategoryModel>>> getCategories() =>
      _store.read(StorageKeys.categories, CategoryModel.listFromJson);

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) => _store.write(
    StorageKeys.categories,
    categories.map((category) => category.toJson()).toList(),
    maxBytes: maxEntryBytes,
  );
}
