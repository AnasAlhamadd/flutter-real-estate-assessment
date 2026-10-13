import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';

const PropertyExtrasEntity _sample = PropertyExtrasMockDataSource.sample;

PropertyExtrasEntity _with({int bedrooms = 8, int bathrooms = 3}) =>
    PropertyExtrasEntity(
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqft: _sample.areaSqft,
      agent: _sample.agent,
      facilities: _sample.facilities,
      address: _sample.address,
    );

Future<void> _pump(
  WidgetTester tester,
  PropertyExtrasEntity extras, {
  Locale locale = AppLocalization.english,
  Size size = const Size(430, 932),
  double textScale = 1,
}) => pumpLocalizedWidget(
  tester,
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: DetailsStats(extras: extras),
  ),
  locale: locale,
  size: size,
  textScale: textScale,
);

void main() {
  testWidgets('shows beds, baths and area like Figma', (tester) async {
    await _pump(tester, _sample);

    expect(find.text('8 Beds'), findsOneWidget);
    expect(find.text('3 baths'), findsOneWidget);
    expect(find.text('2000 sqft'), findsOneWidget);
    expect(
      tester
          .widgetList<AppSvgIcon>(find.byType(AppSvgIcon))
          .map((icon) => icon.assetPath),
      [ImagePath.statBed, ImagePath.statBath, ImagePath.statArea],
    );
  });

  testWidgets('English singular', (tester) async {
    await _pump(tester, _with(bedrooms: 1, bathrooms: 1));

    expect(find.text('1 Bed'), findsOneWidget);
    expect(find.text('1 bath'), findsOneWidget);
  });

  testWidgets('Arabic plural forms', (tester) async {
    for (final (count, beds, baths) in [
      (1, 'غرفة نوم واحدة', 'حمّام واحد'),
      (2, 'غرفتا نوم', 'حمّامان'),
      (8, '8 غرف نوم', '8 حمّامات'),
      (11, '11 غرفة نوم', '11 حمّامًا'),
    ]) {
      await _pump(
        tester,
        _with(bedrooms: count, bathrooms: count),
        locale: AppLocalization.arabic,
      );

      expect(find.text(beds), findsOneWidget, reason: '$count');
      expect(find.text(baths), findsOneWidget, reason: '$count');
    }
    expect(find.text('2000 قدم²'), findsOneWidget);
  });

  testWidgetsInLayouts('wraps instead of overflowing', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(
      tester,
      _sample,
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, locale);
  });
}
