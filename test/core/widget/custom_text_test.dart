import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/layout_expectations.dart';
import '../../helpers/pump_widget.dart';
import '../../helpers/translations.dart';

const _spaced = TextStyle(fontSize: 12, letterSpacing: 1.2);

Text _textOf(WidgetTester tester) => tester.widget<Text>(
  find.descendant(of: find.byType(CustomText), matching: find.byType(Text)),
);

void main() {
  testWidgetsInLayouts('shows the translation of its key', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.commonRetry),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expect(find.text(translate(locale, 'common.retry')), findsOneWidget);
  });

  testWidgets('passes style, alignment, max lines and overflow to Text', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(
        AppTextKeys.commonEmpty,
        style: _spaced,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final text = _textOf(tester);
    expect(text.style, _spaced);
    expect(text.textAlign, TextAlign.center);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('upper-cases the translation when asked', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.splashTagline, upperCase: true),
    );

    expect(
      find.text(
        translate(AppLocalization.english, 'splash.tagline').toUpperCase(),
      ),
      findsOneWidget,
    );
  });

  testWidgets('keeps letter spacing in the English locale', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.splashTagline, style: _spaced),
    );

    expect(_textOf(tester).style?.letterSpacing, 1.2);
  });

  testWidgets('drops letter spacing in the Arabic locale', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.splashTagline, style: _spaced),
      locale: AppLocalization.arabic,
    );

    final style = _textOf(tester).style!;
    expect(style.letterSpacing, 0);
    expect(style.fontSize, _spaced.fontSize);
  });

  testWidgets('drops letter spacing for Latin text in the Arabic locale', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.appTitle, style: _spaced),
      locale: AppLocalization.arabic,
    );

    expect(_textOf(tester).style?.letterSpacing, 0);
  });

  testWidgets('rebuilds with the new language after a locale change', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.commonRetry),
    );

    await tester
        .element(find.byType(CustomText))
        .setLocale(AppLocalization.arabic);
    await tester.pumpAndSettle();

    expect(
      find.text(translate(AppLocalization.arabic, 'common.retry')),
      findsOneWidget,
    );
  });
}
