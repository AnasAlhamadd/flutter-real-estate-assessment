import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/section_status_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

void main() {
  group('SectionStatusView', () {
    testWidgets('empty shows the translated empty message', (tester) async {
      await pumpLocalizedWidget(
        tester,
        const SingleChildScrollView(
          child: SectionStatusView.empty(minHeight: 120),
        ),
        locale: AppLocalization.arabic,
      );

      expect(tester.getSize(find.byType(SectionStatusView)).height, 120);

      expect(
        find.text(translate(AppLocalization.arabic, 'common.empty')),
        findsOneWidget,
      );
    });

    testWidgetsInLayouts('failure shows the message and retries', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      var retries = 0;
      await pumpLocalizedWidget(
        tester,
        SingleChildScrollView(
          child: SectionStatusView.failure(
            failure: const TimeoutFailure(),
            onRetry: () => retries++,
            minHeight: 120,
          ),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text(translate(locale, 'errors.timeout')), findsOneWidget);
      await tester.tap(find.text(translate(locale, 'common.retry')));
      expect(retries, 1);
    });
  });
}
