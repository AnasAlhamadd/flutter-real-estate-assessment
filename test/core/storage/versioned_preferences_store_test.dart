import 'dart:convert';

import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/storage/versioned_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mocks.dart';

const _key = 'entry';

void main() {
  final now = DateTime.utc(2026, 10, 13, 12);
  late SharedPreferences preferences;
  late VersionedPreferencesStore store;

  Future<void> createWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    preferences = await SharedPreferences.getInstance();
    store = VersionedPreferencesStore(
      preferences,
      schemaVersion: 2,
      clock: () => now,
    );
  }

  setUp(() => createWith({}));

  Object? identity(Object? data) => data;

  test('writes an envelope and reads the data back with its time', () async {
    expect(await store.write(_key, {'a': 1}, maxBytes: 1024), isTrue);

    expect(store.contains(_key), isTrue);
    expect(jsonDecode(preferences.getString(_key)!), {
      'schemaVersion': 2,
      'cachedAt': now.toIso8601String(),
      'data': {'a': 1},
    });
    final entry = await store.read(_key, identity);
    expect(entry, CachedEntry<Object?>(data: const {'a': 1}, cachedAt: now));
  });

  test('skips entries larger than the limit', () async {
    expect(await store.write(_key, 'x' * 200, maxBytes: 100), isFalse);
    expect(store.contains(_key), isFalse);
  });

  test('reading a missing key throws', () async {
    await expectLater(
      store.read(_key, identity),
      throwsA(const CacheException()),
    );
  });

  for (final (name, raw) in [
    ('an older schema', jsonEncode({'schemaVersion': 1, 'data': 1})),
    ('invalid JSON', '{not json'),
    ('no timestamp', jsonEncode({'schemaVersion': 2, 'data': 1})),
    ('a non-object', jsonEncode([1, 2])),
  ]) {
    test('removes $name and throws', () async {
      await createWith({_key: raw});

      await expectLater(
        store.read(_key, identity),
        throwsA(const CacheException()),
      );
      expect(store.contains(_key), isFalse);
    });
  }

  test('removes data the parser rejects', () async {
    await store.write(_key, 1, maxBytes: 1024);

    await expectLater(
      store.read<int>(_key, (_) => throw const FormatException('bad')),
      throwsA(const CacheException()),
    );
    expect(store.contains(_key), isFalse);
  });

  test('a value that is not a string is removed', () async {
    await createWith({_key: 42});

    await expectLater(
      store.read(_key, identity),
      throwsA(const CacheException()),
    );
    expect(store.contains(_key), isFalse);
  });

  test('data JSON cannot encode throws', () async {
    await expectLater(
      store.write(_key, Object(), maxBytes: 1024),
      throwsA(const CacheException()),
    );
  });

  test('a failed write throws', () async {
    final failing = MockSharedPreferences();
    when(() => failing.setString(any(), any())).thenAnswer((_) async => false);
    final failingStore = VersionedPreferencesStore(failing, schemaVersion: 1);

    await expectLater(
      failingStore.write(_key, 1, maxBytes: 1024),
      throwsA(const CacheException()),
    );
  });
}
