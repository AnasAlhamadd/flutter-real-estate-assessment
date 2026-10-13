import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/category_chip.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/loading_view.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/home_category_chips.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/home_header.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/section_status_view.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/sliver_property_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_properties_repository.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

DateTime _at(int hour) => DateTime(2026, 10, 13, hour);

void main() {
  group('HomeHeader', () {
    test('greets by time of day', () {
      expect(HomeHeader.greetingKeyFor(_at(5)), AppTextKeys.homeGoodMorning);
      expect(HomeHeader.greetingKeyFor(_at(11)), AppTextKeys.homeGoodMorning);
      expect(HomeHeader.greetingKeyFor(_at(12)), AppTextKeys.homeGoodAfternoon);
      expect(HomeHeader.greetingKeyFor(_at(16)), AppTextKeys.homeGoodAfternoon);
      expect(HomeHeader.greetingKeyFor(_at(17)), AppTextKeys.homeGoodEvening);
      expect(HomeHeader.greetingKeyFor(_at(0)), AppTextKeys.homeGoodEvening);
      expect(HomeHeader.greetingKeyFor(_at(4)), AppTextKeys.homeGoodEvening);
    });

    testWidgetsInLayouts('shows the greeting and the guest welcome line', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        Padding(
          padding: const EdgeInsets.all(20),
          child: HomeHeader(now: _at(9)),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(find.text(translate(locale, 'home.good_morning')), findsOneWidget);
      expect(
        find.text(translate(locale, 'home.welcome_guest')),
        findsOneWidget,
      );
    });

    testWidgetsInLayouts('puts the avatar on the reading-start side', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        HomeHeader(now: _at(20)),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      final avatar = tester.getCenter(find.byType(ExcludeSemantics).last);
      final greeting = tester.getCenter(
        find.text(translate(locale, 'home.good_evening')),
      );
      if (directionOf(locale) == TextDirection.ltr) {
        expect(avatar.dx, lessThan(greeting.dx));
      } else {
        expect(avatar.dx, greaterThan(greeting.dx));
      }
    });

    testWidgets('keeps a 44×44 avatar at the design size', (tester) async {
      await pumpLocalizedWidget(tester, HomeHeader(now: _at(9)));

      final avatar = find.descendant(
        of: find.byType(HomeHeader),
        matching: find.byType(Container),
      );
      expect(tester.getSize(avatar), const Size(44, 44));
    });
  });

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

  group('SectionStatusView', () {
    testWidgets('loading reserves the given height inside a scroll view', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const SingleChildScrollView(
          child: SectionStatusView.loading(minHeight: 200),
        ),
        settle: false,
      );

      expect(find.byType(LoadingView), findsOneWidget);
      expect(tester.getSize(find.byType(SectionStatusView)).height, 200);
    });

    testWidgets('empty shows the translated empty message', (tester) async {
      await pumpLocalizedWidget(
        tester,
        const SectionStatusView.empty(minHeight: 120),
        locale: AppLocalization.arabic,
      );

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
