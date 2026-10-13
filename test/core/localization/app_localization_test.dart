import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wrap configures both languages, English fallback and saving', () {
    final widget = AppLocalization.wrap(const SizedBox()) as EasyLocalization;

    expect(widget.supportedLocales, AppLocalization.supportedLocales);
    expect(widget.fallbackLocale, AppLocalization.english);
    expect(widget.saveLocale, isTrue);
    expect(widget.useOnlyLangCode, isTrue);
  });

  test('wrap applies real plural rules (Arabic few/many forms)', () {
    final widget = AppLocalization.wrap(const SizedBox()) as EasyLocalization;

    expect(widget.ignorePluralRules, isFalse);
  });
}
