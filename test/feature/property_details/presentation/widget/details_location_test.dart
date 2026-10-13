import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_location.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';

final String _address = PropertyExtrasMockDataSource.sample.address;

Future<void> _pump(
  WidgetTester tester, {
  String? address,
  Locale locale = AppLocalization.english,
  Size size = const Size(430, 932),
  double textScale = 1,
}) => pumpLocalizedWidget(
  tester,
  SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: DetailsLocation(address: address ?? _address),
  ),
  locale: locale,
  size: size,
  textScale: textScale,
);

void main() {
  testWidgets('shows the title, address and the static map', (tester) async {
    await _pump(tester);

    expect(find.text('Location'), findsOneWidget);
    expect(find.text(_address), findsOneWidget);
    expect(find.byType(DetailsMap), findsOneWidget);
  });

  testWidgets('the map keeps the Figma ratio at the content width', (
    tester,
  ) async {
    await _pump(tester);

    final map = tester.getSize(find.byType(DetailsMap));
    expect(map.width, closeTo(430 - 48, 0.5));
    expect(
      map.width / map.height,
      closeTo(AppSizes.detailsMapSize.aspectRatio, 0.01),
    );
  });

  testWidgets('the map is one image for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester);

    expect(find.bySemanticsLabel('Map of the property location'), findsOne);
    expect(find.bySemanticsLabel('9 Evergreen Center'), findsNothing);
    semantics.dispose();
  });

  testWidgets('the mock map art, pin and photo are drawn', (tester) async {
    await _pump(tester);

    final svgs = tester.widgetList<SvgPicture>(
      find.descendant(
        of: find.byType(DetailsMap),
        matching: find.byType(SvgPicture),
      ),
    );
    expect(svgs.map((svg) => (svg.bytesLoader as SvgAssetLoader).assetName), [
      ImagePath.detailsMap,
      ImagePath.mapPin,
    ]);
    expect(
      tester
          .widget<Image>(
            find.descendant(
              of: find.byType(DetailsMap),
              matching: find.byType(Image),
            ),
          )
          .image,
      const AssetImage(ImagePath.mapPinPhoto),
    );
    for (final street in DetailsMap.streetNames) {
      expect(find.text(street.text), findsOneWidget, reason: street.text);
    }
  });

  testWidgets('Arabic mirrors the address row but not the map', (tester) async {
    await _pump(tester, locale: AppLocalization.arabic);

    expect(find.text('الموقع'), findsOneWidget);
    final icon = tester.getRect(
      find.descendant(
        of: find.byType(DetailsLocation),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is AppSvgIcon &&
              widget.assetPath == ImagePath.locationBold,
        ),
      ),
    );
    expect(icon.right, closeTo(430 - 24, 0.5));
    expect(
      tester.getRect(find.text(_address)).right,
      closeTo(icon.left - AppSizes.detailsLocationIconGap, 0.5),
    );
    final map = tester.getRect(find.byType(DetailsMap));
    final street = tester.getCenter(find.text('9 Evergreen Center'));
    expect(street.dx - map.left, lessThan(map.width / 2));
  });

  testWidgetsInLayouts('a long address wraps without overflow', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(
      tester,
      address: 'A very long street name and building number, ' * 4,
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
  });
}
