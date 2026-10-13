import 'dart:io';

import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/translations.dart';

/// Values of every `static const String` in `AppTextKeys`, read from the
/// source so a new constant is checked without being listed here.
Set<String> _declaredKeys() {
  final source = File(
    'lib/core/constant/app_text_keys.dart',
  ).readAsStringSync();
  return RegExp(
    r"static const String \w+ =\s*'([^']+)';",
  ).allMatches(source).map((match) => match.group(1)!).toSet();
}

void main() {
  final declared = _declaredKeys();

  test('declares at least one key', () {
    expect(declared, isNotEmpty);
  });

  for (final locale in AppLocalization.supportedLocales) {
    test('declares exactly the keys of ${locale.languageCode}.json', () {
      final keys = flattenTranslations(readTranslations(locale)).keys.toSet();

      expect(declared.difference(keys), isEmpty, reason: 'missing in JSON');
      expect(keys.difference(declared), isEmpty, reason: 'not in AppTextKeys');
    });
  }
}
