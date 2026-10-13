import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_card_skeletons.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_list_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/sliver_property_list.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/sample_properties.dart';

Widget _scroll(Widget sliver) => CustomScrollView(
  slivers: [
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: sliver,
    ),
  ],
);

void main() {
  group('SliverPropertyList', () {
    testWidgetsInLayouts('shows one card per property, 16 apart', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        _scroll(
          SliverPropertyList(
            properties: sampleProperties.take(2).toList(),
            onTap: (_) {},
          ),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      final cards = find.byType(PropertyListCard);
      expect(cards, findsNWidgets(2));
      final gap =
          tester.getRect(cards.at(1)).top - tester.getRect(cards.at(0)).bottom;
      if (size == AppSizes.designSize) {
        expect(gap, closeTo(AppSizes.listGap, 0.01));
      } else {
        expect(gap, greaterThan(0));
      }
    });

    testWidgets('passes the tapped property and the category name', (
      tester,
    ) async {
      PropertyEntity? tapped;
      await pumpLocalizedWidget(
        tester,
        _scroll(
          SliverPropertyList(
            properties: const [
              PropertyEntity(
                id: 7,
                title: 'No brand',
                price: 10,
                rating: 4,
                category: 'beauty',
              ),
            ],
            categoryNameFor: (slug) => slug == 'beauty' ? 'Beauty' : null,
            onTap: (property) => tapped = property,
          ),
        ),
      );

      expect(find.text('Beauty'), findsOneWidget);
      await tester.tap(find.text('No brand'));
      expect(tapped?.id, 7);
    });

    testWidgets('builds a heart for each card from the builder', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        _scroll(
          SliverPropertyList(
            properties: sampleProperties.take(2).toList(),
            onTap: (_) {},
            favoriteButtonBuilder: (property) =>
                SizedBox(key: ValueKey('heart-${property.id}')),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('heart-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('heart-2')), findsOneWidget);
    });
  });

  group('SliverPropertyListSkeleton', () {
    testWidgets('shows the requested number of skeleton cards', (tester) async {
      await pumpLocalizedWidget(
        tester,
        _scroll(const SliverPropertyListSkeleton(count: 3)),
        settle: false,
      );

      expectNoLayoutErrors(tester);
      expect(find.byType(PropertyListCardSkeleton), findsNWidgets(3));
    });
  });
}
