import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_header.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/property_tag.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/sample_properties.dart';

void main() {
  test('category label turns the slug into words', () {
    expect(DetailsHeader.categoryLabel('home-decoration'), 'home decoration');
    expect(DetailsHeader.categoryLabel('beauty'), 'beauty');
  });

  testWidgets('shows the title, category tag and rating', (tester) async {
    await pumpLocalizedWidget(
      tester,
      DetailsHeader(property: sampleDetailedProperty, reviewCount: 3),
    );

    expect(find.text(sampleDetailedProperty.title), findsOneWidget);
    expect(find.widgetWithText(PropertyTag, 'BEAUTY'), findsOneWidget);
    expect(find.text('4.9 (3 reviews)'), findsOneWidget);
  });

  testWidgets('shows only the rating while the reviews are unknown', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      DetailsHeader(property: sampleProperties.first),
    );

    expect(find.text('4.9'), findsOneWidget);
  });

  testWidgetsInLayouts('wraps a long title and tag row without overflow', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    const property = PropertyEntity(
      id: 7,
      title: 'An Extremely Long Product Title That Wraps Over Lines',
      price: 1,
      rating: 4.5,
      category: 'mobile-accessories-and-more-categories',
    );
    await pumpLocalizedWidget(
      tester,
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: DetailsHeader(property: property, reviewCount: 3),
      ),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, locale);
  });

  testWidgets('puts the tag at the start in Arabic', (tester) async {
    await pumpLocalizedWidget(
      tester,
      DetailsHeader(property: sampleDetailedProperty, reviewCount: 3),
      locale: AppLocalization.arabic,
    );

    final tag = tester.getRect(find.byType(PropertyTag));
    final rating = tester.getRect(find.text('4.9 (3 تقييمات)'));
    expect(tag.left, greaterThan(rating.right));
  });
}
