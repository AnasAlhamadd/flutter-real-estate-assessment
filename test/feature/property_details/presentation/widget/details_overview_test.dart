import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_overview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

void main() {
  testWidgetsInLayouts('shows the translated title and the description', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      SingleChildScrollView(
        child: DetailsOverview(description: 'A long description. ' * 20),
      ),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expect(find.text(translate(locale, 'details.overview')), findsOneWidget);
    expect(find.textContaining('A long description.'), findsOneWidget);
  });

  testWidgets('loading: three skeleton lines announced as loading', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const DetailsOverview.loading(),
      settle: false,
    );

    expect(find.byType(SkeletonTextLine), findsNWidgets(3));
    expect(
      find.bySemanticsLabel(
        translate(AppLocalization.english, 'common.loading'),
      ),
      findsOneWidget,
    );
  });
}
