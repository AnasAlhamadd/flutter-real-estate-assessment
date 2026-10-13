import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_header.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

void main() {
  group('SearchHeader', () {
    testWidgetsInLayouts('shows the back button and the title', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        Padding(
          padding: const EdgeInsets.all(20),
          child: SearchHeader(onBack: () {}),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expectVisibleAndTappable(tester, find.byType(AppBackButton));
      expect(find.text(translate(locale, 'explore.title')), findsOneWidget);
    });

    testWidgetsInLayouts('keeps the title centered on the row', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SearchHeader(onBack: () {}),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      final row = tester.getRect(find.byType(SearchHeader));
      final title = tester.getRect(
        find.text(translate(locale, 'explore.title')),
      );
      expect(title.center.dx, closeTo(row.center.dx, 0.01));
    });

    for (final locale in AppLocalization.supportedLocales) {
      testWidgets('puts the back button on the reading-start side in '
          '${locale.languageCode}', (tester) async {
        await pumpLocalizedWidget(
          tester,
          SearchHeader(onBack: () {}),
          locale: locale,
        );

        final back = tester.getRect(find.byType(AppBackButton));
        final row = tester.getRect(find.byType(SearchHeader));
        if (locale == AppLocalization.arabic) {
          expect(back.right, row.right);
        } else {
          expect(back.left, row.left);
        }
      });
    }

    testWidgets('calls onBack when the back button is tapped', (tester) async {
      var taps = 0;
      await pumpLocalizedWidget(tester, SearchHeader(onBack: () => taps++));

      await tester.tap(find.byType(AppBackButton));

      expect(taps, 1);
    });
  });
}
