import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/category_chip.dart';
import 'package:flutter_real_estate_assessment/core/widget/load_more_error_view.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/filter_sheet.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/price_histogram_bars.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_properties_repository.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/test_viewports.dart';
import '../../../../helpers/translations.dart';

const Locale _en = AppLocalization.english;
const Locale _ar = AppLocalization.arabic;

Finder _inSheet(Finder finder) =>
    find.descendant(of: find.byType(FilterSheet), matching: finder);

/// Opens the sheet from Explore's filter icon. Pass `settle: false` while
/// the price skeleton shimmers.
Future<void> _openSheet(
  WidgetTester tester, {
  FakePropertiesRepository? properties,
  Locale locale = _en,
  TestViewport viewport = defaultViewport,
  double textScale = 1,
  bool settle = true,
}) async {
  await pumpApp(
    tester,
    initialLocation: AppRouter.explore,
    properties: properties,
    locale: locale,
    viewport: viewport,
    textScale: textScale,
  );
  await tester.tap(
    find.byWidgetPredicate(
      (widget) => widget is AppSvgIcon && widget.assetPath == ImagePath.filter,
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

/// The 32 px circle inside the back button's tap target.
Rect _backCircle(WidgetTester tester) => Rect.fromCenter(
  center: tester.getCenter(_inSheet(find.byType(AppBackButton))),
  width: 32,
  height: 32,
);

void main() {
  group('Figma layout (430 × 932)', () {
    testWidgets('places the header, price chart, chips and button with the '
        'Figma gaps', (tester) async {
      await _openSheet(tester);

      final sheet = tester.getRect(find.byType(FilterSheet));
      final back = _backCircle(tester);
      final title = tester.getRect(
        _inSheet(find.text(translate(_en, 'common.filter'))),
      );
      final reset = tester.getRect(
        _inSheet(find.text(translate(_en, 'filter.reset'))),
      );
      final priceTitle = tester.getRect(
        _inSheet(find.text(translate(_en, 'filter.price_range'))),
      );
      final bars = tester.getRect(_inSheet(find.byType(PriceHistogramBars)));
      final slider = tester.getRect(_inSheet(find.byType(RangeSlider)));
      final typeTitle = tester.getRect(
        _inSheet(find.text(translate(_en, 'filter.property_type'))),
      );
      final firstChip = tester.getRect(
        _inSheet(find.byType(CategoryChip)).first,
      );
      final button = tester.getRect(_inSheet(find.byType(AppButton)));

      expect(sheet.bottom, 932);
      expect(back.top, closeTo(sheet.top + 24, 0.01));
      expect(back.left, closeTo(20, 0.01));
      expect(title.center.dx, closeTo(215, 0.01));
      expect(title.center.dy, closeTo(back.center.dy, 0.01));
      expect(reset.right, closeTo(410, 0.01));
      expect(priceTitle.top, closeTo(back.bottom + 32, 0.01));
      expect(priceTitle.left, 20);
      expect(priceTitle.height, closeTo(24, 0.01));
      expect(bars.top, closeTo(priceTitle.bottom + 16, 0.01));
      expect(bars.width, 390);
      expect(bars.height, closeTo(58, 0.01));
      expect(slider.center.dy, closeTo(bars.bottom, 0.01));
      expect(slider.height, 24);
      expect(slider.width, 390);
      expect(typeTitle.top, greaterThan(slider.bottom + 8 + 16));
      expect(firstChip.top, closeTo(typeTitle.bottom + 16, 0.01));
      expect(button.left, 20);
      expect(button.width, 390);
      expect(button.height, 54);
      expect(button.bottom, closeTo(932 - 34 - 14, 0.01));
    });

    testWidgets('mirrors the header in Arabic', (tester) async {
      await _openSheet(tester, locale: _ar);

      final back = _backCircle(tester);
      final reset = tester.getRect(
        _inSheet(find.text(translate(_ar, 'filter.reset'))),
      );
      expect(back.right, closeTo(410, 0.01));
      expect(reset.left, closeTo(20, 0.01));
    });

    testWidgets('lists every API category as a chip, none selected', (
      tester,
    ) async {
      await _openSheet(tester);

      final chips = tester.widgetList<CategoryChip>(
        _inSheet(find.byType(CategoryChip)),
      );
      expect(chips.map((chip) => chip.label), [
        for (final category in sampleCategories) category.name,
      ]);
      expect(chips.any((chip) => chip.selected), isFalse);
    });
  });

  group('price states', () {
    testWidgets('shows a skeleton while prices load, with the chips and '
        'button usable', (tester) async {
      final gate = Completer<void>();
      final properties = FakePropertiesRepository()..fullSetGate = gate.future;
      await _openSheet(tester, properties: properties, settle: false);

      expect(_inSheet(find.byType(AppShimmer)), findsOneWidget);
      expect(_inSheet(find.byType(RangeSlider)), findsNothing);
      expect(_inSheet(find.byType(CategoryChip)), findsNWidgets(3));
      expect(_inSheet(find.byType(AppButton)).hitTestable(), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(_inSheet(find.byType(AppShimmer)), findsNothing);
      expect(_inSheet(find.byType(RangeSlider)), findsOneWidget);
    });

    testWidgets('a failed price load offers a retry', (tester) async {
      final properties = FakePropertiesRepository(
        fullSets: {'': const Left(NetworkFailure())},
      );
      await _openSheet(tester, properties: properties);

      expect(_inSheet(find.byType(LoadMoreErrorView)), findsOneWidget);

      properties.fullSets = {};
      await tester.tap(_inSheet(find.text(translate(_en, 'common.retry'))));
      await tester.pumpAndSettle();

      expect(_inSheet(find.byType(LoadMoreErrorView)), findsNothing);
      expect(_inSheet(find.byType(RangeSlider)), findsOneWidget);
      expect(properties.fullSetRequests, ['', '']);
    });

    testWidgets('a single price disables the slider', (tester) async {
      final properties = FakePropertiesRepository(
        fullSets: {
          '': Right(pageOf([sampleProperties.first])),
        },
      );
      await _openSheet(tester, properties: properties);

      final slider = tester.widget<RangeSlider>(
        _inSheet(find.byType(RangeSlider)),
      );
      expect(slider.onChanged, isNull);
    });
  });

  group('responsive layout', () {
    for (final viewport in testViewports) {
      for (final locale in AppLocalization.supportedLocales) {
        for (final textScale in const [1.0, 1.3]) {
          testWidgets('lays out without overflow on $viewport · '
              '${locale.languageCode} · x$textScale', (tester) async {
            await _openSheet(
              tester,
              locale: locale,
              viewport: viewport,
              textScale: textScale,
            );

            expectNoLayoutErrors(tester);
            expectVisibleAndTappable(
              tester,
              _inSheet(find.byType(AppBackButton)),
            );
            expectVisibleAndTappable(tester, _inSheet(find.byType(AppButton)));
            expect(
              tester.getSize(find.byType(FilterSheet)).height,
              lessThanOrEqualTo(viewport.size.height * 758 / 932 + 0.01),
            );
          });
        }
      }
    }
  });
}
