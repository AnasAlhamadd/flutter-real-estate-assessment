import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_hero.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_page_dots.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_widget.dart';

const double _hero = AppSizes.detailsHeroHeight;

/// The hero in a bouncing scroll view with a long body under it.
Future<PageController> _pump(WidgetTester tester, List<String?> urls) async {
  final controller = PageController();
  addTearDown(controller.dispose);
  await pumpLocalizedWidget(
    tester,
    CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        DetailsHero(
          imageUrls: urls,
          controller: controller,
          topBar: const SizedBox(key: Key('top-bar'), height: 10),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 2000)),
      ],
    ),
  );
  return controller;
}

Finder get _photos => find.byType(PageView);

double _scale(WidgetTester tester) => tester
    .widget<Transform>(
      find.ancestor(of: _photos, matching: find.byType(Transform)).first,
    )
    .transform
    .getMaxScaleOnAxis();

ImageFiltered _blur(WidgetTester tester) => tester.widget<ImageFiltered>(
  find.ancestor(of: _photos, matching: find.byType(ImageFiltered)),
);

/// Drags the body by [dy] and holds it there (no fling, no release).
Future<TestGesture> _hold(WidgetTester tester, double dy) async {
  final gesture = await tester.startGesture(const Offset(215, 700));
  await gesture.moveBy(Offset(0, dy.sign * 20));
  await gesture.moveBy(Offset(0, dy - dy.sign * 20));
  await tester.pump();
  return gesture;
}

void main() {
  testWidgets('full width, Figma height, top bar on top', (tester) async {
    await _pump(tester, ['', '']);

    expect(tester.getSize(_photos), const Size(430, _hero));
    expect(tester.getTopLeft(find.byKey(const Key('top-bar'))).dy, 0);
  });

  testWidgets('at rest: no zoom, no blur', (tester) async {
    await _pump(tester, ['', '']);

    expect(_scale(tester), 1);
    expect(_blur(tester).enabled, isFalse);
  });

  testWidgets('pulling down zooms with the drag, release settles back', (
    tester,
  ) async {
    await _pump(tester, ['', '']);

    final gesture = await _hold(tester, 100);
    final small = _scale(tester);
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    final large = _scale(tester);

    expect(small, greaterThan(1));
    expect(large, greaterThan(small));
    expect(_blur(tester).enabled, isFalse);
    expect(tester.getRect(_photos).top, 0, reason: 'zooms from the top edge');

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
  });

  testWidgets('scrolling away blurs in step with the offset', (tester) async {
    await _pump(tester, ['', '']);
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;

    position.jumpTo(_hero / 4);
    await tester.pump();
    final quarter = _blur(tester);
    position.jumpTo(_hero / 2);
    await tester.pump();
    final half = _blur(tester);

    expect(quarter.enabled, isTrue);
    expect(_scale(tester), 1);
    expect(half.imageFilter, isNot(quarter.imageFilter));
    expect(
      tester.getTopLeft(find.byKey(const Key('top-bar'))).dy,
      closeTo(-_hero / 2, 1),
      reason: 'moves up with the content',
    );
  });

  testWidgets('a dark gradient sits at the bottom, under the dots', (
    tester,
  ) async {
    await _pump(tester, ['', '', '']);

    final gradient = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          (widget.decoration as BoxDecoration?)?.gradient != null,
    );
    final rect = tester.getRect(gradient);
    expect(rect.bottom, _hero);
    expect(rect.height, AppSizes.detailsHeroGradientHeight);
    final dots = tester.getRect(find.byType(DetailsPageDots));
    expect(rect.contains(dots.center), isTrue);
  });

  testWidgets('swiping pages through the photos', (tester) async {
    final controller = await _pump(tester, ['', '', '']);

    await tester.fling(_photos, const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(controller.page, 1);
    expect(find.bySemanticsLabel('Image 2 of 3'), findsOneWidget);
  });

  testWidgets('dots sit 16 above the bottom, centered', (tester) async {
    await _pump(tester, ['', '', '']);

    final dots = tester.getRect(find.byType(DetailsPageDots));
    expect(dots.bottom, _hero - AppSizes.detailsDotsBottom);
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
