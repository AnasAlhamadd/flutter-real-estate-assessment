import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_reviews.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/review_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/translations.dart';

Future<void> _pump(
  WidgetTester tester,
  List<ReviewEntity> reviews, {
  List<int> likes = const [],
  Locale locale = AppLocalization.english,
  Size size = const Size(430, 932),
  double textScale = 1,
}) => pumpLocalizedWidget(
  tester,
  SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: DetailsReviews(
      rating: 4.94,
      reviews: reviews,
      now: sampleNow,
      likes: likes,
    ),
  ),
  locale: locale,
  size: size,
  textScale: textScale,
);

final List<ReviewEntity> _reviews = sampleDetailedProperty.reviews;

void main() {
  testWidgets('passes each review its likes; missing ones get none', (
    tester,
  ) async {
    await _pump(tester, _reviews, likes: const [938, 254]);
    await tester.tap(find.text('See All'));
    await tester.pumpAndSettle();

    final tiles = tester.widgetList<ReviewTile>(find.byType(ReviewTile));
    expect(tiles.map((tile) => tile.likes), [938, 254, null]);
  });

  testWidgets('shows the summary with the star and the first review', (
    tester,
  ) async {
    await _pump(tester, _reviews);

    expect(find.text('4.9 (3 reviews)'), findsOneWidget);
    expect(
      tester.widget<AppSvgIcon>(find.byType(AppSvgIcon).first).assetPath,
      ImagePath.star,
    );
    expect(find.byType(ReviewTile), findsOneWidget);
    expect(find.text(_reviews.first.comment), findsOneWidget);
  });

  testWidgets('"See All" shows every review, then disappears', (tester) async {
    await _pump(tester, _reviews);

    await tester.tap(find.text('See All'));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewTile), findsNWidgets(3));
    expect(find.text('See All'), findsNothing);
  });

  testWidgets('no "See All" for a single review', (tester) async {
    await _pump(tester, _reviews.take(1).toList());

    expect(find.text('See All'), findsNothing);
    expect(find.text('4.9 (1 review)'), findsOneWidget);
  });

  testWidgetsInLayouts('lays out expanded without overflow', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(
      tester,
      _reviews,
      locale: locale,
      size: size,
      textScale: textScale,
    );
    await tester.tap(find.text(translate(locale, 'common.see_all')));
    await tester.pumpAndSettle();

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, locale);
    expect(find.byType(ReviewTile), findsNWidgets(3));
  });
}
