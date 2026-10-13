import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';

Map<String, dynamic> readTranslations(Locale locale) =>
    jsonDecode(
          File(
            '${AppLocalization.translationsPath}/${locale.languageCode}.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

/// Resolves a dotted key straight from the JSON file, independent of the app.
String translate(Locale locale, String key) {
  Object? node = readTranslations(locale);
  for (final part in key.split('.')) {
    node = (node as Map<String, dynamic>)[part];
  }
  return node! as String;
}

/// Reads the real translation files synchronously, which keeps widget tests
/// deterministic inside the fake-async zone.
class FileAssetLoader extends AssetLoader {
  const FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      readTranslations(locale);
}
