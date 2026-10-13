import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/translations.dart';

void main() {
  final en = flattenTranslations(readTranslations(AppLocalization.english));
  final ar = flattenTranslations(readTranslations(AppLocalization.arabic));

  test('English and Arabic define exactly the same keys', () {
    expect(ar.keys.toSet(), en.keys.toSet());
  });

  test('no translation is empty', () {
    for (final entry in [...en.entries, ...ar.entries]) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });
}
