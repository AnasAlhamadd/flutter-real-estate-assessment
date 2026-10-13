import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/translations.dart';

Map<String, String> _flatten(Map<String, dynamic> json, [String prefix = '']) {
  final result = <String, String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      result.addAll(_flatten(value, path));
    } else {
      result[path] = value as String;
    }
  });
  return result;
}

void main() {
  final en = _flatten(readTranslations(AppLocalization.english));
  final ar = _flatten(readTranslations(AppLocalization.arabic));

  test('English and Arabic define exactly the same keys', () {
    expect(ar.keys.toSet(), en.keys.toSet());
  });

  test('no translation is empty', () {
    for (final entry in [...en.entries, ...ar.entries]) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });
}
