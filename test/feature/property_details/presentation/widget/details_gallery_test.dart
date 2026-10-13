import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_gallery.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

Future<List<int>> _pump(
  WidgetTester tester,
  int count, {
  Locale locale = AppLocalization.english,
  Size size = const Size(430, 932),
  double textScale = 1,
}) async {
  final taps = <int>[];
  await pumpLocalizedWidget(
    tester,
    Padding(
      padding: const EdgeInsets.all(20),
      child: DetailsGallery(
        imageUrls: List.filled(count, ''),
        onImageTap: taps.add,
      ),
    ),
    locale: locale,
    size: size,
    textScale: textScale,
  );
  return taps;
}

void main() {
  testWidgets('shows at most three square tiles', (tester) async {
    await _pump(tester, 5);

    expect(find.byType(AppNetworkImage), findsNWidgets(3));
    final tile = tester.getSize(find.byType(AppNetworkImage).first);
    expect(tile.width, closeTo(tile.height, 0.01));
  });

  testWidgets('the last tile counts the photos not shown', (tester) async {
    await _pump(tester, 5);

    expect(find.text('2+'), findsOneWidget);
  });

  testWidgets('no count when every photo has a tile', (tester) async {
    await _pump(tester, 3);

    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('two photos keep the tile size of three', (tester) async {
    await _pump(tester, 2);

    expect(find.byType(AppNetworkImage), findsNWidgets(2));
    final tile = tester.getSize(find.byType(AppNetworkImage).first);
    expect(tile.width, closeTo((390 - 2 * 17) / 3, 0.5));
  });

  testWidgets('reports the tapped tile index', (tester) async {
    final taps = await _pump(tester, 5);

    await tester.tap(find.byType(AppNetworkImage).at(1));
    await tester.tap(find.text('2+'));

    expect(taps, [1, 2]);
  });

  testWidgets('tiles are announced as buttons with their position', (
    tester,
  ) async {
    await _pump(tester, 5);

    expect(find.bySemanticsLabel('Show image 3 of 5'), findsOneWidget);
  });

  for (final locale in AppLocalization.supportedLocales) {
    testWidgets('first tile at the reading start (${locale.languageCode})', (
      tester,
    ) async {
      await _pump(tester, 3, locale: locale);

      final first = tester.getRect(find.byType(AppNetworkImage).at(0));
      final second = tester.getRect(find.byType(AppNetworkImage).at(1));
      expect(
        first.left < second.left,
        directionOf(locale) == TextDirection.ltr,
      );
      expect(find.text(translate(locale, 'details.gallery')), findsOneWidget);
    });
  }

  testWidgetsInLayouts('lays out without overflow', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(tester, 6, locale: locale, size: size, textScale: textScale);

    expectNoLayoutErrors(tester);
  });
}
