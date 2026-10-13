import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_price_bar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';

Future<void> _pump(
  WidgetTester tester, {
  double price = 17821,
  Locale locale = AppLocalization.english,
  Size size = AppSizes.designSize,
  double textScale = 1,
}) => pumpLocalizedWidget(
  tester,
  Align(
    alignment: Alignment.bottomCenter,
    child: DetailsPriceBar(price: price),
  ),
  locale: locale,
  size: size,
  textScale: textScale,
);

void main() {
  testWidgets('shows "PRICE" and the Figma price format', (tester) async {
    await _pump(tester);

    expect(find.text('PRICE'), findsOneWidget);
    expect(find.text(r'$17821'), findsOneWidget);
  });

  testWidgets('keeps cents from the API', (tester) async {
    await _pump(tester, price: 9.99);

    expect(find.text(r'$9.99'), findsOneWidget);
  });

  testWidgets('Arabic label, price kept as Latin digits', (tester) async {
    await _pump(tester, locale: AppLocalization.arabic);

    expect(find.text('السعر'), findsOneWidget);
    expect(find.text(r'$17821'), findsOneWidget);
  });

  testWidgets('has no booking button (Q9)', (tester) async {
    await _pump(tester);

    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('full width, rounded top, Primary 10% border', (tester) async {
    await _pump(tester);

    expect(
      tester.getSize(find.byType(DetailsPriceBar)).width,
      AppSizes.designSize.width,
    );
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(DetailsPriceBar),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(decoration.border, Border.all(color: ColorsApp.primary10));
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusPriceBar),
      ),
    );
  });

  testWidgetsInLayouts('lays out without overflow', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(
      tester,
      price: 36999.99,
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
  });
}
