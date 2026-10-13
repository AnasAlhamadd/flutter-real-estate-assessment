import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_page_dots.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_widget.dart';

List<AnimatedContainer> _dots(WidgetTester tester) => tester
    .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
    .toList();

Color? _colorOf(AnimatedContainer dot) =>
    (dot.decoration! as BoxDecoration).color;

void main() {
  testWidgets('the current page is the wide Primary pill', (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);
    await pumpLocalizedWidget(
      tester,
      Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              children: const [SizedBox(), SizedBox(), SizedBox()],
            ),
          ),
          DetailsPageDots(count: 3, controller: controller),
        ],
      ),
    );

    expect(_dots(tester), hasLength(3));
    expect(_colorOf(_dots(tester)[0]), ColorsApp.primary);
    expect(
      tester.getSize(find.byType(AnimatedContainer).at(0)),
      const Size(AppSizes.detailsDotActiveWidth, AppSizes.detailsDotSize),
    );
    expect(_colorOf(_dots(tester)[1]), ColorsApp.white);

    controller.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(_colorOf(_dots(tester)[0]), ColorsApp.white);
    expect(_colorOf(_dots(tester)[2]), ColorsApp.primary);
    expect(
      tester.getSize(find.byType(AnimatedContainer).at(0)),
      const Size.square(AppSizes.detailsDotSize),
    );
  });
}
