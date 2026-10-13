import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/sliver_property_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';

void main() {
  group('SliverPropertyGrid', () {
    test('fits two columns on phones and more on wide screens', () {
      expect(SliverPropertyGrid.columnsFor(240, gap: 11), 2);
      expect(SliverPropertyGrid.columnsFor(390, gap: 16), 2);
      expect(SliverPropertyGrid.columnsFor(696, gap: 28.6), 3);
      expect(SliverPropertyGrid.columnsFor(846, gap: 34.7), 3);
      expect(SliverPropertyGrid.columnsFor(2000, gap: 16), 4);
    });

    Future<void> pumpGrid(
      WidgetTester tester,
      Size size, {
      ValueChanged<int>? onTap,
    }) => pumpLocalizedWidget(
      tester,
      CustomScrollView(
        slivers: [
          SliverPropertyGrid(
            properties: sampleProperties,
            categoryNameFor: (slug) => slug.toUpperCase(),
            onTap: (property) => onTap?.call(property.id),
          ),
        ],
      ),
      size: size,
    );

    testWidgets('lays two cards per row at the design width', (tester) async {
      await pumpGrid(tester, AppSizes.designSize);

      expectNoLayoutErrors(tester);
      final first = tester.getRect(find.byType(PropertyGridCard).at(0));
      final second = tester.getRect(find.byType(PropertyGridCard).at(1));
      final third = tester.getRect(find.byType(PropertyGridCard).at(2));
      expect(first.top, second.top);
      expect(third.top, greaterThan(first.bottom));
      expect(second.left - first.right, closeTo(16, 0.01));
    });

    testWidgets('uses three columns on a 768-wide screen', (tester) async {
      await pumpGrid(tester, const Size(768, 1024));

      final tops = tester
          .widgetList<PropertyGridCard>(find.byType(PropertyGridCard))
          .take(3)
          .map((card) => tester.getRect(find.byWidget(card)).top)
          .toSet();
      expect(tops, hasLength(1));
    });

    testWidgets('passes the category name and the tapped id', (tester) async {
      final taps = <int>[];
      await pumpGrid(tester, AppSizes.designSize, onTap: taps.add);

      expect(find.text('BEAUTY'), findsOneWidget);
      await tester.tap(find.text('Eyeshadow Palette with Mirror'));
      expect(taps, [2]);
    });
  });
}
