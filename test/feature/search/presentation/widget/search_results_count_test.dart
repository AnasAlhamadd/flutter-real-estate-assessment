import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_results_count.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

String _form(String form, int count, Locale locale) =>
    translate(locale, 'search.found.$form').replaceAll('{}', '$count');

void main() {
  group('SearchResultsCount', () {
    for (final (locale, count, form) in const [
      (AppLocalization.english, 1, 'one'),
      (AppLocalization.english, 182, 'other'),
      (AppLocalization.arabic, 1, 'one'),
      (AppLocalization.arabic, 2, 'two'),
      (AppLocalization.arabic, 5, 'few'),
      (AppLocalization.arabic, 11, 'many'),
      (AppLocalization.arabic, 100, 'other'),
    ]) {
      testWidgets('uses the "$form" form for $count in '
          '${locale.languageCode}', (tester) async {
        await pumpLocalizedWidget(
          tester,
          SearchResultsCount(total: count),
          locale: locale,
        );

        expect(find.text(_form(form, count, locale)), findsOneWidget);
      });
    }

    testWidgets('uses the section title style', (tester) async {
      await pumpLocalizedWidget(tester, const SearchResultsCount(total: 3));

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, AppTextStyles.sectionTitle.fontSize);
      expect(text.style?.fontWeight, AppTextStyles.sectionTitle.fontWeight);
    });

    testWidgetsInLayouts('fits large numbers on narrow screens', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const Padding(
          padding: EdgeInsets.all(20),
          child: SearchResultsCount(total: 123456),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
    });
  });
}
