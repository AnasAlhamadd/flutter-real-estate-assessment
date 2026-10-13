import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_hero.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_page_dots.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_widget.dart';

Future<PageController> _pump(WidgetTester tester, List<String?> urls) async {
  final controller = PageController();
  addTearDown(controller.dispose);
  await pumpLocalizedWidget(
    tester,
    Align(
      alignment: Alignment.topCenter,
      child: DetailsHero(
        imageUrls: urls,
        controller: controller,
        topBar: const SizedBox(key: Key('top-bar'), height: 10),
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets('full width, Figma height, top bar on top', (tester) async {
    await _pump(tester, ['', '']);

    expect(
      tester.getSize(find.byType(DetailsHero)),
      const Size(430, AppSizes.detailsHeroHeight),
    );
    expect(tester.getTopLeft(find.byKey(const Key('top-bar'))).dy, 0);
  });

  testWidgets('swiping pages through the photos', (tester) async {
    final controller = await _pump(tester, ['', '', '']);

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(controller.page, 1);
    expect(find.bySemanticsLabel('Image 2 of 3'), findsOneWidget);
  });

  testWidgets('dots sit 16 above the bottom, centered', (tester) async {
    await _pump(tester, ['', '', '']);

    final dots = tester.getRect(find.byType(DetailsPageDots));
    expect(
      dots.bottom,
      AppSizes.detailsHeroHeight - AppSizes.detailsDotsBottom,
    );
    expect(dots.center.dx, closeTo(215, 0.5));
  });

  testWidgets('a single photo has no dots; null shows the placeholder', (
    tester,
  ) async {
    await _pump(tester, [null]);

    expect(find.byType(DetailsPageDots), findsNothing);
    expect(find.byType(AppNetworkImage), findsOneWidget);
  });
}
