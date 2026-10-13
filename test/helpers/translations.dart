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

/// Leaf translations by dotted key, e.g. `common.retry`.
Map<String, String> flattenTranslations(
  Map<String, dynamic> json, [
  String prefix = '',
]) {
  final result = <String, String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      result.addAll(flattenTranslations(value, path));
    } else {
      result[path] = value as String;
    }
  });
  return result;
}

const Set<String> _pluralForms = {'zero', 'one', 'two', 'few', 'many', 'other'};

/// A plural group: only plural form names, `other` included. Languages
/// need different forms (Arabic six, English two), so a group is one key.
bool _isPluralGroup(Map<String, dynamic> node) =>
    node.containsKey('other') && node.keys.every(_pluralForms.contains);

/// Dotted translation keys as the app uses them: plural groups count as one
/// key (e.g. `time.days_ago`), other nested maps are walked.
Set<String> translationKeys(Map<String, dynamic> json, [String prefix = '']) {
  final keys = <String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic> && !_isPluralGroup(value)) {
      keys.addAll(translationKeys(value, path));
    } else {
      keys.add(path);
    }
  });
  return keys;
}

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
