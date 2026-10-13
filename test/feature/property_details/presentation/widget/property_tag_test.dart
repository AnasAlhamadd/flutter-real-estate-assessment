import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/property_tag.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';

void main() {
  testWidgets('shows the label uppercase on a Primary 4% pill', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const Center(child: PropertyTag(label: 'home decoration')),
    );

    expect(find.text('HOME DECORATION'), findsOneWidget);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(PropertyTag),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, ColorsApp.primary4);
  });

  testWidgetsInLayouts('ellipsizes a label wider than the screen', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      PropertyTag(label: 'very long category ' * 10),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
  });
}
