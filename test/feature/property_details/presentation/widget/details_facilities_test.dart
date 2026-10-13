import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_facilities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

Future<void> _pump(
  WidgetTester tester, {
  List<PropertyFacility> facilities = PropertyFacility.values,
  Locale locale = AppLocalization.english,
  Size size = const Size(430, 932),
  double textScale = 1,
}) => pumpLocalizedWidget(
  tester,
  SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: DetailsFacilities(facilities: facilities),
  ),
  locale: locale,
  size: size,
  textScale: textScale,
);

Rect _iconRect(WidgetTester tester, PropertyFacility facility) =>
    tester.getRect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppSvgIcon &&
            widget.assetPath == DetailsFacilities.contentOf(facility).icon,
      ),
    );

void main() {
  test('every facility has its own icon and a translated label', () {
    final contents = PropertyFacility.values.map(DetailsFacilities.contentOf);

    expect(contents.map((content) => content.icon).toSet(), hasLength(8));
    expect(
      contents.map((content) => content.icon),
      everyElement(isIn(ImagePath.icons)),
    );
    for (final locale in AppLocalization.supportedLocales) {
      final keys = translationKeys(readTranslations(locale));
      for (final content in contents) {
        expect(keys, contains(content.label), reason: '$locale');
      }
    }
  });

  testWidgets('shows the title and the eight Figma facilities', (tester) async {
    await _pump(tester);

    expect(find.text('Facilities'), findsOneWidget);
    for (final label in [
      'Car Parking',
      'Swimming Pool',
      'Gym & Fitness',
      'Restaurant',
      'Wi-fi & Network',
      'Pet Center',
      'Sport Center',
      'Laundry',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('four per row, in order', (tester) async {
    await _pump(tester);

    final first = PropertyFacility.values
        .take(4)
        .map((facility) => _iconRect(tester, facility));
    final second = PropertyFacility.values
        .skip(4)
        .map((facility) => _iconRect(tester, facility));
    expect(first.map((rect) => rect.top).toSet(), hasLength(1));
    expect(second.first.top, greaterThan(first.first.bottom));
    expect(
      first.map((rect) => rect.left).toList(),
      orderedEquals(first.map((rect) => rect.left).toList()..sort()),
    );
    expect(second.first.left, closeTo(first.first.left, 0.5));
  });

  testWidgets('an incomplete last row keeps the column widths', (tester) async {
    await _pump(tester, facilities: PropertyFacility.values.take(5).toList());

    expect(
      _iconRect(tester, PropertyFacility.values[4]).left,
      closeTo(_iconRect(tester, PropertyFacility.values[0]).left, 0.5),
    );
  });

  testWidgets('Arabic starts the rows on the right', (tester) async {
    await _pump(tester, locale: AppLocalization.arabic);

    expect(find.text('المرافق'), findsOneWidget);
    expect(
      _iconRect(tester, PropertyFacility.carParking).left,
      greaterThan(_iconRect(tester, PropertyFacility.restaurant).left),
    );
  });

  testWidgetsInLayouts('long labels are ellipsized without overflow', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(tester, locale: locale, size: size, textScale: textScale);

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, locale);
  });
}
