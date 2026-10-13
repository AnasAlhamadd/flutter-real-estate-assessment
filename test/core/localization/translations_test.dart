import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/translations.dart';

void main() {
  final en = flattenTranslations(readTranslations(AppLocalization.english));
  final ar = flattenTranslations(readTranslations(AppLocalization.arabic));

  test('English and Arabic define exactly the same keys', () {
    expect(
      translationKeys(readTranslations(AppLocalization.arabic)),
      translationKeys(readTranslations(AppLocalization.english)),
    );
  });

  test('every plural group has an "other" form', () {
    for (final key in [...en.keys, ...ar.keys]) {
      final parts = key.split('.');
      if (!{'zero', 'one', 'two', 'few', 'many'}.contains(parts.last)) {
        continue;
      }
      final other = [...parts.take(parts.length - 1), 'other'].join('.');
      expect(
        en.containsKey(other) && ar.containsKey(other),
        isTrue,
        reason: key,
      );
    }
  });

  test('no translation is empty', () {
    for (final entry in [...en.entries, ...ar.entries]) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });
}
