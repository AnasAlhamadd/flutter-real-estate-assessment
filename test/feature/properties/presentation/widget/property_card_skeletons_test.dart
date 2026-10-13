import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/featured_property_list.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_card_skeletons.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/sliver_property_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

Widget _grid(Widget sliver) => CustomScrollView(
  slivers: [
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: sliver,
    ),
  ],
);

void main() {
  testWidgetsInLayouts('Featured skeletons have the card size and row', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const FeaturedPropertyListSkeleton(),
      locale: locale,
      size: size,
      textScale: textScale,
      settle: false,
    );
    final skeletonSize = tester.getSize(
      find.byType(FeaturedPropertyCardSkeleton).first,
    );

    await pumpLocalizedWidget(
      tester,
      FeaturedPropertyList(properties: sampleProperties, onTap: (_) {}),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expect(
      skeletonSize,
      tester.getSize(find.byType(FeaturedPropertyCard).first),
    );
  });

  for (final locale in AppLocalization.supportedLocales) {
    testWidgets(
      'Featured skeletons start from the reading start (${locale.languageCode})',
      (tester) async {
        await pumpLocalizedWidget(
          tester,
          const FeaturedPropertyListSkeleton(),
          locale: locale,
          settle: false,
        );
        final first = tester.getRect(
          find.byType(FeaturedPropertyCardSkeleton).first,
        );
        final rtl = directionOf(locale) == TextDirection.rtl;
        expect(
          rtl ? AppSizes.designSize.width - first.right : first.left,
          closeTo(AppSizes.screenHorizontalPadding, 0.01),
        );
      },
    );
  }

  testWidgetsInLayouts('grid skeletons are as tall as the real cards', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      _grid(const SliverPropertyGridSkeleton(rows: 1)),
      locale: locale,
      size: size,
      textScale: textScale,
      settle: false,
    );
    final skeleton = tester.getRect(
      find.byType(PropertyGridCardSkeleton).first,
    );
    final bars = find.descendant(
      of: find.byType(PropertyGridCardSkeleton).first,
      matching: find.byType(SkeletonBox),
    );
    expect(bars, findsNWidgets(4));
    for (final bar in bars.evaluate()) {
      final rect = tester.getRect(find.byWidget(bar.widget));
      expect(rect.width, greaterThan(skeleton.width / 4));
      expect(rect.height, greaterThan(0));
    }

    await pumpLocalizedWidget(
      tester,
      _grid(
        SliverPropertyGrid(
          properties: sampleProperties.take(2).toList(),
          onTap: (_) {},
          favoriteButtonBuilder: (_) => const SizedBox.square(dimension: 44),
        ),
      ),
      locale: locale,
      size: size,
      textScale: textScale,
    );
    final card = tester.getRect(find.byType(PropertyGridCard).first);

    expectNoLayoutErrors(tester);
    expect(skeleton.width, card.width);
    expect(skeleton.height, closeTo(card.height, 1));
  });

  for (final (width, columns) in const [(430.0, 2), (932.0, 4)]) {
    testWidgets('one skeleton row fills all $columns columns at $width', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        _grid(const SliverPropertyGridSkeleton(rows: 1)),
        size: Size(width, 932),
        settle: false,
      );

      expect(find.byType(PropertyGridCardSkeleton), findsNWidgets(columns));
    });
  }

  testWidgets('screen readers hear "Loading" once per skeleton group', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLocalizedWidget(
      tester,
      const Column(
        children: [
          FeaturedPropertyListSkeleton(),
          Expanded(child: _GridSkeleton()),
        ],
      ),
      settle: false,
    );

    expect(
      find.bySemanticsLabel(
        translate(AppLocalization.english, 'common.loading'),
      ),
      findsNWidgets(2),
    );
    expect(find.byType(SkeletonBox), findsWidgets);
    semantics.dispose();
  });
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) =>
      _grid(const SliverPropertyGridSkeleton(rows: 1));
}
