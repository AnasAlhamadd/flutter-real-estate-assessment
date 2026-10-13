import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_divider.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/pages/property_details_screen.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_gallery.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_overview.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_price_bar.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_reviews.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_skeleton.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/fake_properties_repository.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/test_viewports.dart';
import '../../../../helpers/translations.dart';

const Locale _en = AppLocalization.english;
final PropertyEntity _listing = sampleProperties.first;

/// Opens Details from Home (so Back has somewhere to go), optionally with
/// the listing item as `extra`. Pumps frames instead of settling while
/// [settle] is false, because skeletons never settle.
Future<void> _open(
  WidgetTester tester, {
  required FakePropertiesRepository properties,
  int id = 1,
  PropertyEntity? initial,
  Locale locale = _en,
  TestViewport viewport = defaultViewport,
  double textScale = 1,
  bool settle = true,
}) async {
  await pumpApp(
    tester,
    properties: properties,
    locale: locale,
    viewport: viewport,
    textScale: textScale,
  );
  unawaited(
    GoRouter.of(
      tester.element(find.byType(HomeScreen)),
    ).push(AppRouter.propertyDetailsPath(id), extra: initial),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) =>
    tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(PropertyDetailsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );

void main() {
  group('loading', () {
    testWidgets('without list data: skeleton, back button, no price', (
      tester,
    ) async {
      final properties = FakePropertiesRepository()..gate = Completer().future;
      await _open(tester, properties: properties, settle: false);

      expect(find.byType(DetailsSkeleton), findsOneWidget);
      expectVisibleAndTappable(tester, find.byType(AppBackButton));
      expect(find.byType(FavoriteButton), findsNothing);
      expect(find.byType(DetailsPriceBar), findsNothing);
    });

    testWidgets('with list data: title, price and heart at once; the '
        'overview loads', (tester) async {
      final gate = Completer<void>();
      final properties = FakePropertiesRepository()..gate = gate.future;
      await _open(
        tester,
        properties: properties,
        initial: _listing,
        settle: false,
      );

      expect(find.text(_listing.title), findsOneWidget);
      expect(find.text(r'$9.99'), findsOneWidget);
      expect(find.byType(FavoriteButton), findsOneWidget);
      expect(find.byType(DetailsSkeleton), findsNothing);
      expect(find.byType(DetailsOverview), findsOneWidget);
      expect(find.text(sampleDetailedProperty.description!), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.text(sampleDetailedProperty.description!), findsOneWidget);
      expect(properties.detailRequests, [1]);
    });
  });

  group('success', () {
    testWidgets('shows the designed sections that have API data', (
      tester,
    ) async {
      await _open(tester, properties: FakePropertiesRepository());

      expect(find.text(_listing.title), findsOneWidget);
      expect(find.text('BEAUTY'), findsOneWidget);
      expect(find.text('4.9 (3 reviews)'), findsWidgets);
      expect(find.byType(AppDivider), findsOneWidget);
      expect(find.text(translate(_en, 'details.overview')), findsOneWidget);
      await _scrollTo(tester, find.byType(DetailsReviews));
      expect(find.byType(DetailsGallery), findsOneWidget);
      expect(find.byType(DetailsReviews), findsOneWidget);
      expect(find.byType(DetailsPriceBar), findsOneWidget);
    });

    testWidgets('hides the sections without API data (Q4, Q9)', (tester) async {
      await _open(tester, properties: FakePropertiesRepository());
      await _scrollTo(tester, find.byType(DetailsReviews));

      for (final text in [
        'Agent',
        'Facilities',
        'Location',
        'Booking Now',
        'Beds',
      ]) {
        expect(find.textContaining(text), findsNothing, reason: text);
      }
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('no gallery for a single photo, no overview or reviews '
        'without data', (tester) async {
      final properties = FakePropertiesRepository(
        details: {
          1: const Right(
            PropertyEntity(
              id: 1,
              title: 'Bare product',
              price: 5,
              rating: 3,
              category: 'beauty',
              imageUrls: [''],
            ),
          ),
        },
      );
      await _open(tester, properties: properties);

      expect(find.text('Bare product'), findsOneWidget);
      expect(find.byType(DetailsOverview), findsNothing);
      expect(find.byType(DetailsGallery), findsNothing);
      expect(find.byType(DetailsReviews), findsNothing);
    });

    testWidgets('a gallery tile opens that photo in the hero at the top', (
      tester,
    ) async {
      await _open(tester, properties: FakePropertiesRepository());
      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(PropertyDetailsScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await _scrollTo(tester, find.text('2+'));
      expect(scrollable.position.pixels, greaterThan(0));

      await tester.tap(find.text('2+'));
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, 0);
      expect(find.bySemanticsLabel('Image 3 of 5'), findsOneWidget);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.page, 2);
    });

    testWidgets('the heart is shared with Home', (tester) async {
      await _open(
        tester,
        properties: FakePropertiesRepository(),
        initial: _listing,
      );

      await tester.tap(find.byType(FavoriteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      final homeHearts = tester.widgetList<FavoriteButton>(
        find.byType(FavoriteButton),
      );
      expect(homeHearts.where((heart) => heart.isFavorite), isNotEmpty);
    });
  });

  group('failure', () {
    testWidgets('without list data: message and retry under a back button', (
      tester,
    ) async {
      final properties = FakePropertiesRepository(
        details: {1: const Left(NetworkFailure())},
      );
      await _open(tester, properties: properties);

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text(translate(_en, 'errors.no_internet')), findsOneWidget);
      expectVisibleAndTappable(tester, find.byType(AppBackButton));
      expect(find.byType(DetailsPriceBar), findsNothing);

      properties.details = {1: Right(sampleDetailedProperty)};
      await tester.tap(find.text(translate(_en, 'common.retry')));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text(sampleDetailedProperty.description!), findsOneWidget);
      expect(properties.detailRequests, [1, 1]);
    });

    testWidgets('with list data: keeps the header and price, retries the '
        'details in place', (tester) async {
      final properties = FakePropertiesRepository(
        details: {1: const Left(TimeoutFailure())},
      );
      await _open(tester, properties: properties, initial: _listing);

      expect(find.text(_listing.title), findsOneWidget);
      expect(find.byType(DetailsPriceBar), findsOneWidget);
      await _scrollTo(tester, find.byType(ErrorView));
      expect(find.text(translate(_en, 'errors.timeout')), findsOneWidget);

      properties.details = {1: Right(sampleDetailedProperty)};
      await tester.tap(find.text(translate(_en, 'common.retry')));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text(sampleDetailedProperty.description!), findsOneWidget);
    });

    testWidgets('an unknown id says it was not found', (tester) async {
      await _open(tester, properties: FakePropertiesRepository(), id: 999);

      expect(find.text(translate(_en, 'errors.not_found')), findsOneWidget);
    });
  });

  group('routing', () {
    testWidgets('a non-numeric id shows the not-found page without a '
        'request', (tester) async {
      final properties = FakePropertiesRepository();
      await pumpApp(
        tester,
        properties: properties,
        initialLocation: '/property/abc',
      );

      expect(find.byType(PropertyDetailsScreen), findsNothing);
      expect(
        find.text(translate(_en, 'errors.page_not_found')),
        findsOneWidget,
      );
      expect(properties.detailRequests, isEmpty);
    });

    testWidgets('extra for another id is not used as initial data', (
      tester,
    ) async {
      final properties = FakePropertiesRepository()..gate = Completer().future;
      await _open(
        tester,
        properties: properties,
        initial: sampleProperties[2],
        settle: false,
      );

      expect(find.byType(DetailsSkeleton), findsOneWidget);
      expect(find.text(sampleProperties[2].title), findsNothing);
    });
  });

  group('layout', () {
    for (final locale in AppLocalization.supportedLocales) {
      for (final viewport in testViewports) {
        for (final textScale in [1.0, 1.3]) {
          testWidgets('no overflow, controls in reach on $viewport · '
              '${locale.languageCode} · x$textScale', (tester) async {
            await _open(
              tester,
              properties: FakePropertiesRepository(),
              locale: locale,
              viewport: viewport,
              textScale: textScale,
            );

            expectNoLayoutErrors(tester);
            expectDirectionFor(tester, locale);
            expectVisibleAndTappable(tester, find.byType(AppBackButton));
            expectVisibleAndTappable(tester, find.byType(FavoriteButton));

            final seeAll = find.text(translate(locale, 'common.see_all'));
            await _scrollTo(tester, seeAll);
            await tester.tap(seeAll);
            await tester.pumpAndSettle();
            await _scrollTo(
              tester,
              find.text(sampleDetailedProperty.reviews.last.comment),
            );
            await tester.pumpAndSettle();
            expectNoLayoutErrors(tester);
          });
        }
      }
    }
  });
}
