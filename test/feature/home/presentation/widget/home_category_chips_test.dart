import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/category_chip.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/home_category_chips.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

void main() {
  group('HomeCategoryChips', () {
    testWidgetsInLayouts('shows "All" first, then the API categories', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        HomeCategoryChips(
          categories: sampleCategories,
          selectedSlug: null,
          onSelected: (_) {},
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      final labels = tester
          .widgetList<CategoryChip>(find.byType(CategoryChip))
          .map((chip) => chip.label)
          .toList();
      expect(labels, [
        translate(locale, 'common.all'),
        'Beauty',
        'Fragrances',
        'Furniture',
      ]);
      final all = tester.widget<CategoryChip>(find.byType(CategoryChip).first);
      expect(all.selected, isTrue);
    });

    testWidgets('reports the tapped category, and null for "All"', (
      tester,
    ) async {
      final selections = <String?>[];
      await pumpLocalizedWidget(
        tester,
        HomeCategoryChips(
          categories: sampleCategories,
          selectedSlug: 'beauty',
          onSelected: selections.add,
        ),
      );

      await tester.tap(find.text('Fragrances'));
      await tester.tap(
        find.text(translate(AppLocalization.english, 'common.all')),
      );

      expect(selections, ['fragrances', null]);
      final beauty = tester.widget<CategoryChip>(
        find.widgetWithText(CategoryChip, 'Beauty'),
      );
      expect(beauty.selected, isTrue);
    });

    testWidgets('scrolls horizontally instead of overflowing', (tester) async {
      final many = [
        for (var i = 0; i < 20; i++)
          CategoryEntity(slug: 'category-$i', name: 'Category number $i'),
      ];
      await pumpLocalizedWidget(
        tester,
        HomeCategoryChips(
          categories: many,
          selectedSlug: null,
          onSelected: (_) {},
        ),
        size: narrowSize,
        textScale: largeTextScale,
      );

      expectNoLayoutErrors(tester);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.axis, Axis.horizontal);
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
    });
  });
}
