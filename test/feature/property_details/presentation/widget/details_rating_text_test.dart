import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_rating_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_widget.dart';

Future<String> _text(
  WidgetTester tester, {
  required Locale locale,
  int? count,
}) async {
  late String result;
  await pumpLocalizedWidget(
    tester,
    Builder(
      builder: (context) {
        result = detailsRatingText(context, rating: 4.84, reviewCount: count);
        return const SizedBox();
      },
    ),
    locale: locale,
  );
  return result;
}

void main() {
  testWidgets('shows only the rating until the reviews are loaded', (
    tester,
  ) async {
    expect(await _text(tester, locale: AppLocalization.english), '4.8');
  });

  testWidgets('English: singular and plural review counts', (tester) async {
    const en = AppLocalization.english;
    expect(await _text(tester, locale: en, count: 1), '4.8 (1 review)');
    expect(await _text(tester, locale: en, count: 3), '4.8 (3 reviews)');
  });

  testWidgets('Arabic: plural forms with Western digits', (tester) async {
    const ar = AppLocalization.arabic;
    expect(await _text(tester, locale: ar, count: 0), '4.8 (لا توجد تقييمات)');
    expect(await _text(tester, locale: ar, count: 1), '4.8 (تقييم واحد)');
    expect(await _text(tester, locale: ar, count: 2), '4.8 (تقييمان)');
    expect(await _text(tester, locale: ar, count: 3), '4.8 (3 تقييمات)');
    expect(await _text(tester, locale: ar, count: 11), '4.8 (11 تقييمًا)');
    expect(await _text(tester, locale: ar, count: 100), '4.8 (100 تقييم)');
  });
}
