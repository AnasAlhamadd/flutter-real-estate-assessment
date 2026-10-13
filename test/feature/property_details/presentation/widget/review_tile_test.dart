import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/review_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/sample_properties.dart';

Future<void> _pump(
  WidgetTester tester,
  ReviewEntity review, {
  int? likes,
  Locale locale = AppLocalization.english,
  Size size = const Size(430, 932),
  double textScale = 1,
}) => pumpLocalizedWidget(
  tester,
  SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: ReviewTile(review: review, now: sampleNow, likes: likes),
  ),
  locale: locale,
  size: size,
  textScale: textScale,
);

ReviewEntity _reviewAgo(Duration elapsed) => ReviewEntity(
  reviewerName: 'Eleanor Collins',
  comment: 'Great',
  rating: 5,
  date: sampleNow.subtract(elapsed),
);

void main() {
  test('initials come from the first two words', () {
    expect(ReviewTile.initialsOf('Eleanor Collins'), 'EC');
    expect(ReviewTile.initialsOf('  lucas   gordon  smith '), 'LG');
    expect(ReviewTile.initialsOf('Zoe'), 'Z');
    expect(ReviewTile.initialsOf('   '), '');
  });

  testWidgets('shows initials, name, comment and how long ago', (tester) async {
    await _pump(tester, sampleDetailedProperty.reviews.first);

    expect(find.text('EC'), findsOneWidget);
    expect(find.text('Eleanor Collins'), findsOneWidget);
    expect(find.text('Would not recommend!'), findsOneWidget);
    expect(find.text('6 days ago'), findsOneWidget);
  });

  testWidgets('a reviewer without a name gets the profile icon', (
    tester,
  ) async {
    await _pump(
      tester,
      const ReviewEntity(reviewerName: '', comment: 'Fine', rating: 4),
    );

    expect(
      tester.widget<AppSvgIcon>(find.byType(AppSvgIcon)).assetPath,
      ImagePath.profileLight,
    );
  });

  testWidgets('no date, no time line', (tester) async {
    await _pump(
      tester,
      const ReviewEntity(reviewerName: 'Zoe', comment: 'Fine', rating: 4),
    );

    expect(find.textContaining('ago'), findsNothing);
  });

  testWidgets('likes: Primary heart and count, a plural label', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, sampleDetailedProperty.reviews.first, likes: 938);

    expect(find.text('938'), findsOneWidget);
    final heart = tester.widget<AppSvgIcon>(
      find.byWidgetPredicate(
        (widget) => widget is AppSvgIcon && widget.assetPath == ImagePath.heart,
      ),
    );
    expect(heart.color, ColorsApp.primary);
    expect(find.bySemanticsLabel('938 likes'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Arabic likes label uses the plural forms', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      sampleDetailedProperty.reviews.first,
      likes: 938,
      locale: AppLocalization.arabic,
    );

    expect(find.bySemanticsLabel('938 إعجابًا'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('likes without a date keep the likes row', (tester) async {
    await _pump(
      tester,
      const ReviewEntity(reviewerName: 'Zoe', comment: 'Fine', rating: 4),
      likes: 1,
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.textContaining('ago'), findsNothing);
  });

  testWidgets('English relative times', (tester) async {
    for (final (elapsed, text) in [
      (const Duration(seconds: 5), 'Just now'),
      (const Duration(minutes: 1), '1 minute ago'),
      (const Duration(hours: 2), '2 hours ago'),
      (const Duration(days: 1), '1 day ago'),
      (const Duration(days: 60), '2 months ago'),
      (const Duration(days: 365), '1 year ago'),
    ]) {
      await _pump(tester, _reviewAgo(elapsed));
      expect(find.text(text), findsOneWidget, reason: '$elapsed');
    }
  });

  testWidgets('Arabic relative times use the Arabic plural forms', (
    tester,
  ) async {
    for (final (elapsed, text) in [
      (const Duration(seconds: 5), 'الآن'),
      (const Duration(days: 1), 'منذ يوم'),
      (const Duration(days: 2), 'منذ يومين'),
      (const Duration(days: 6), 'منذ 6 أيام'),
      (const Duration(days: 11), 'منذ 11 يومًا'),
      (const Duration(hours: 3), 'منذ 3 ساعات'),
    ]) {
      await _pump(tester, _reviewAgo(elapsed), locale: AppLocalization.arabic);
      expect(find.text(text), findsOneWidget, reason: '$elapsed');
    }
  });

  testWidgetsInLayouts('time sits at the end; long text does not overflow', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await _pump(
      tester,
      ReviewEntity(
        reviewerName: 'A Reviewer With An Extremely Long Name ' * 3,
        comment: 'A long comment. ' * 30,
        rating: 4,
        date: sampleNow.subtract(const Duration(days: 6)),
      ),
      likes: 938,
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    final time = tester.getRect(
      find.text(locale == AppLocalization.arabic ? 'منذ 6 أيام' : '6 days ago'),
    );
    if (directionOf(locale) == TextDirection.ltr) {
      expect(time.right, closeTo(size.width - 20, 0.5));
    } else {
      expect(time.left, closeTo(20, 0.5));
    }
  });
}
