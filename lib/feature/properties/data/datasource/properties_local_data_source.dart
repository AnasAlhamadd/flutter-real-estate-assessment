import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/constant/api_constants.dart';
import 'package:flutter_real_estate_assessment/core/constant/storage_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedEntry<T> extends Equatable {
  const CachedEntry({required this.data, required this.cachedAt});

  final T data;
  final DateTime cachedAt;

  @override
  List<Object?> get props => [data, cachedAt];
}

/// The approved persisted cache (reference §4.5.2): the "All" first page and
/// the category list, nothing else.
abstract interface class PropertiesLocalDataSource {
  /// Throws [CacheException] when nothing usable is stored.
  Future<CachedEntry<PropertiesResponseModel>> getFirstPage();

  /// Skips pages over [PropertiesLocalDataSourceImpl.maxFirstPageItems] items
  /// or [PropertiesLocalDataSourceImpl.maxEntryBytes]. Throws
  /// [CacheException] when the page can't be encoded or the write fails.
  Future<void> cacheFirstPage(PropertiesResponseModel page);

  /// Throws [CacheException] when nothing usable is stored.
  Future<CachedEntry<List<CategoryModel>>> getCategories();

  /// Throws [CacheException] when the list can't be encoded or the write
  /// fails.
  Future<void> cacheCategories(List<CategoryModel> categories);
}

class PropertiesLocalDataSourceImpl implements PropertiesLocalDataSource {
  PropertiesLocalDataSourceImpl(this._preferences, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Bump when the stored JSON shape changes; older entries are then dropped.
  static const int schemaVersion = 1;
  static const int maxEntryBytes = 32 * 1024;
  static const int maxFirstPageItems = ApiConstants.pageSize;

  final SharedPreferences _preferences;
  final DateTime Function() _clock;

  @override
  Future<CachedEntry<PropertiesResponseModel>> getFirstPage() =>
      _read(StorageKeys.productsFirstPage, (data) {
        if (data is! Map<String, dynamic>) {
          throw const FormatException('Cached page is not an object');
        }
        return PropertiesResponseModel.fromJson(data);
      });

  @override
  Future<void> cacheFirstPage(PropertiesResponseModel page) async {
    if (page.products.length > maxFirstPageItems) return;
    await _write(StorageKeys.productsFirstPage, page.toJson());
  }

  @override
  Future<CachedEntry<List<CategoryModel>>> getCategories() =>
      _read(StorageKeys.categories, CategoryModel.listFromJson);

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) => _write(
    StorageKeys.categories,
    categories.map((category) => category.toJson()).toList(),
  );

  Future<CachedEntry<T>> _read<T>(
    String key,
    T Function(Object? data) parseData,
  ) async {
    final raw = _preferences.get(key);
    if (raw == null) throw const CacheException();
    try {
      if (raw is! String) throw const FormatException('Not a string');
      final envelope = jsonDecode(raw);
      if (envelope is! Map<String, dynamic> ||
          envelope['schemaVersion'] != schemaVersion) {
        throw const FormatException('Unknown cache schema');
      }
      final cachedAt = envelope['cachedAt'];
      if (cachedAt is! String) throw const FormatException('No timestamp');
      return CachedEntry(
        data: parseData(envelope['data']),
        cachedAt: DateTime.parse(cachedAt),
      );
    } on FormatException {
      await _preferences.remove(key);
      throw const CacheException();
    }
  }

  Future<void> _write(String key, Object data) async {
    final String raw;
    try {
      raw = jsonEncode({
        'schemaVersion': schemaVersion,
        'cachedAt': _clock().toUtc().toIso8601String(),
        'data': data,
      });
    } on JsonUnsupportedObjectError {
      throw const CacheException();
    }
    if (utf8.encode(raw).length > maxEntryBytes) return;
    final bool saved;
    try {
      saved = await _preferences.setString(key, raw);
    } on Exception {
      throw const CacheException();
    }
    if (!saved) throw const CacheException();
  }
}
