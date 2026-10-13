import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedEntry<T> extends Equatable {
  const CachedEntry({required this.data, required this.cachedAt});

  final T data;
  final DateTime cachedAt;

  @override
  List<Object?> get props => [data, cachedAt];
}

/// JSON values in [SharedPreferences] wrapped in a
/// `{schemaVersion, cachedAt, data}` envelope (reference §4.5.2).
///
/// A missing, corrupt, or older-schema value counts as "nothing stored": the
/// key is removed and [read] throws [CacheException].
class VersionedPreferencesStore {
  VersionedPreferencesStore(
    this._preferences, {
    required this.schemaVersion,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SharedPreferences _preferences;
  final int schemaVersion;
  final DateTime Function() _clock;

  bool contains(String key) => _preferences.containsKey(key);

  /// [parseData] throws [FormatException] for data it can't read.
  Future<CachedEntry<T>> read<T>(
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

  /// Returns `false` without writing when the encoded entry is larger than
  /// [maxBytes]. Throws [CacheException] when [data] can't be encoded or the
  /// write fails.
  Future<bool> write(String key, Object data, {required int maxBytes}) async {
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
    if (utf8.encode(raw).length > maxBytes) return false;
    final bool saved;
    try {
      saved = await _preferences.setString(key, raw);
    } on Exception {
      throw const CacheException();
    }
    if (!saved) throw const CacheException();
    return true;
  }
}
