import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_bottom_nav_bar.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/scroll_to_top_button.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_state.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/featured_property_list.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_card_skeletons.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/sliver_property_grid.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/pages/property_details_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_favorites_repository.dart';
import '../../../../helpers/fake_home_repository.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';
import '../../../../helpers/home_screen_finders.dart';

const Locale _ar = AppLocalization.arabic;

final List<PropertyEntity> _more = [
  for (var id = 6; id <= 9; id++)
    PropertyEntity(
      id: id,
      title: 'More home $id',
      price: 100.0 * id,
      rating: 4,
      category: 'furniture',
    ),
];

FakeHomeRepository _pagedRepository() => FakeHomeRepository(
  firstPage: Right(pageOf(sampleProperties, hasReachedMax: false)),
  nextPages: {
    1: Right(pageOf([sampleProperties.first, ..._more])),
  },
);

HomeState _homeState(WidgetTester tester) =>
    tester.element(find.byType(HomeView)).read<HomeCubit>().state;

Finder _heartOf(Finder card) =>
    find.descendant(of: card, matching: find.byType(FavoriteButton));

Finder _featuredCard(String title) => find.ancestor(
  of: featuredCardTitled(title),
  matching: find.byType(FeaturedPropertyCard),
);

Finder _gridCard(String title) => find.ancestor(
  of: gridCardTitled(title),
  matching: find.byType(PropertyGridCard),
);

bool _isFavorite(WidgetTester tester, Finder heart) =>
    tester.widget<FavoriteButton>(heart).isFavorite;

Future<void> _scrollHomeToTop(WidgetTester tester) async {
  tester.state<ScrollableState>(homePageScrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
}

Future<void> _pullToRefresh(WidgetTester tester) async {
  await _scrollHomeToTop(tester);
  await tester.fling(homePageScrollable, const Offset(0, 500), 1000);
  await tester.pumpAndSettle();
}

void main() {
  group('favorites', () {
    for (final locale in AppLocalization.supportedLocales) {
      testWidgets('a heart on Featured and on the grid is one favorite '
          '(${locale.languageCode})', (tester) async {
        final favorites = FakeFavoritesRepository();
        final property = sampleProperties.first;
        await pumpApp(tester, locale: locale, favorites: favorites);
        final featuredHeart = _heartOf(_featuredCard(property.title));

        await tester.tap(featuredHeart);
        await tester.pumpAndSettle();
        expect(_isFavorite(tester, featuredHeart), isTrue);
        expect(favorites.saved, [property]);

        await scrollHomeTo(tester, gridCardTitled(property.title));
        final gridHeart = _heartOf(_gridCard(property.title));
        expect(_isFavorite(tester, gridHeart), isTrue);

        await tester.tap(gridHeart);
        await tester.pumpAndSettle();
        expect(favorites.saved, isEmpty);
        await _scrollHomeToTop(tester);
        expect(_isFavorite(tester, featuredHeart), isFalse);
        expectNoLayoutErrors(tester);
      });
    }

    testWidgets('saved favorites are filled when Home opens', (tester) async {
      await pumpApp(
        tester,
        favorites: FakeFavoritesRepository(saved: [sampleProperties[1]]),
      );

      expect(
        _isFavorite(tester, _heartOf(_featuredCard(sampleProperties[1].title))),
        isTrue,
      );
      expect(
        _isFavorite(tester, _heartOf(_featuredCard(sampleProperties[0].title))),
        isFalse,
      );
    });

    testWidgets('tapping a heart does not open the details', (tester) async {
      await pumpApp(tester);

      await tester.tap(_heartOf(_featuredCard(sampleProperties.first.title)));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(PropertyDetailsScreen), findsNothing);
    });
  });

  group('pagination', () {
    testWidgets('scrolling down appends the next page once, without '
        'duplicates', (tester) async {
      final repository = _pagedRepository();
      await pumpApp(tester, repository: repository);

      await scrollHomeToEnd(tester);

      expect(gridCardTitled(_more.last.title), findsOneWidget);
      expect(_homeState(tester).recommendations.map((p) => p.id), [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
      ]);
      expect(repository.pageRequests.where((r) => r == 'all:1'), hasLength(1));
      expect(repository.pageRequests, isNot(contains('all:2')));
      expectNoLayoutErrors(tester);
    });

    testWidgets('shows a skeleton row while the next page loads', (
      tester,
    ) async {
      final gate = Completer<void>();
      final repository = _pagedRepository()..nextPageGate = gate.future;
      await pumpApp(tester, repository: repository, settle: false);

      final position = tester
          .state<ScrollableState>(homePageScrollable)
          .position;
      for (var i = 0; i < 3; i++) {
        position.jumpTo(position.maxScrollExtent);
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(SliverPropertyGridSkeleton), findsOneWidget);
      expect(_homeState(tester).recommendations, hasLength(5));
      expectNoLayoutErrors(tester);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(SliverPropertyGridSkeleton), findsNothing);
      expect(_homeState(tester).recommendations, hasLength(9));
    });

    for (final locale in AppLocalization.supportedLocales) {
      testWidgets('a failed page keeps the cards and retries '
          '(${locale.languageCode})', (tester) async {
        final repository = _pagedRepository()
          ..nextPages = {1: const Left(NetworkFailure())};
        await pumpApp(tester, locale: locale, repository: repository);

        await scrollHomeToEnd(tester);
        final message = find.text(translate(locale, 'errors.no_internet'));
        expect(message, findsOneWidget);
        expect(_homeState(tester).recommendations, hasLength(5));
        await scrollHomeToEnd(tester);
        expect(
          repository.pageRequests.where((r) => r == 'all:1'),
          hasLength(1),
          reason: 'scrolling does not retry a failed page on its own',
        );

        repository.nextPages = {1: Right(pageOf(_more))};
        final retry = find.text(translate(locale, 'common.retry'));
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();

        expect(message, findsNothing);
        expect(_homeState(tester).recommendations, hasLength(9));
        expectNoLayoutErrors(tester);
      });
    }

    testWidgets('a category starts again from its first page', (tester) async {
      final repository = _pagedRepository();
      await pumpApp(tester, repository: repository);
      await scrollHomeToEnd(tester);
      expect(_homeState(tester).recommendations, hasLength(9));

      await tester
          .element(find.byType(HomeView))
          .read<HomeCubit>()
          .selectCategory('furniture');
      await tester.pumpAndSettle();

      expect(_homeState(tester).recommendationsPage, 0);
      expect(repository.pageRequests.last, 'furniture:0');
    });
  });

  group('pull to refresh', () {
    testWidgets('shows the new results', (tester) async {
      final repository = FakeHomeRepository();
      await pumpApp(tester, repository: repository);
      final updated = [
        const PropertyEntity(
          id: 50,
          title: 'Fresh Listing',
          price: 10,
          rating: 5,
          category: 'beauty',
        ),
      ];
      repository.featured = Right(updated);

      await _pullToRefresh(tester);

      expect(featuredCardTitled('Fresh Listing'), findsOneWidget);
      expect(featuredCardTitled(sampleProperties.first.title), findsNothing);
    });

    for (final locale in AppLocalization.supportedLocales) {
      testWidgets('a failure keeps what is shown and says so '
          '(${locale.languageCode})', (tester) async {
        final repository = FakeHomeRepository();
        await pumpApp(tester, locale: locale, repository: repository);
        repository
          ..featured = const Left(NetworkFailure())
          ..firstPage = Right(pageOf(const [], isFromCache: true));

        await _pullToRefresh(tester);

        expect(
          find.text(translate(locale, 'home.refresh_failed')),
          findsOneWidget,
        );
        expect(
          featuredCardTitled(sampleProperties.first.title),
          findsOneWidget,
        );
        expect(_homeState(tester).recommendations, sampleProperties);
        expect(
          find.text(translate(locale, 'errors.no_internet')),
          findsNothing,
          reason: 'content is not replaced by an error',
        );
      });
    }

    testWidgets('shows skeletons until the new data arrives', (tester) async {
      final repository = FakeHomeRepository();
      await pumpApp(tester, repository: repository);
      final gate = Completer<void>();
      repository.gate = gate.future;

      await _scrollHomeToTop(tester);
      await tester.fling(homePageScrollable, const Offset(0, 500), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(FeaturedPropertyListSkeleton), findsOneWidget);
      expect(find.byType(PropertyGridCardSkeleton), findsWidgets);
      expect(find.byType(FeaturedPropertyCard), findsNothing);
      expect(find.byType(PropertyGridCard), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(FeaturedPropertyListSkeleton), findsNothing);
      expect(find.byType(PropertyGridCardSkeleton), findsNothing);
      expect(find.byType(FeaturedPropertyCard), findsWidgets);
      expect(find.byType(PropertyGridCard), findsWidgets);
    });

    testWidgets('works when a section shows an error', (tester) async {
      final repository = FakeHomeRepository(
        featured: const Left(NetworkFailure()),
      );
      await pumpApp(tester, locale: _ar, repository: repository);
      expect(find.byType(FeaturedPropertyCard), findsNothing);

      repository.featured = const Right(sampleProperties);
      await _pullToRefresh(tester);

      expect(find.byType(FeaturedPropertyCard), findsWidgets);
      expect(find.text(translate(_ar, 'home.refresh_failed')), findsNothing);
    });
  });

  group('back to top', () {
    final longPage = [
      for (var id = 100; id < 120; id++)
        PropertyEntity(
          id: id,
          title: 'Listing $id',
          price: id.toDouble(),
          rating: 4,
          category: 'beauty',
        ),
    ];

    bool isShown(WidgetTester tester) =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale == 1;

    for (final locale in AppLocalization.supportedLocales) {
      testWidgets('appears at the end side above the nav bar and returns to '
          'the top (${locale.languageCode})', (tester) async {
        await pumpApp(
          tester,
          locale: locale,
          repository: FakeHomeRepository(firstPage: Right(pageOf(longPage))),
        );
        expect(isShown(tester), isFalse);

        await scrollHomeToEnd(tester);
        expect(isShown(tester), isTrue);

        final button = tester.getRect(find.byType(ScrollToTopButton));
        final screenCenter = tester.view.physicalSize.width / 2;
        if (directionOf(locale) == TextDirection.ltr) {
          expect(button.center.dx, greaterThan(screenCenter));
        } else {
          expect(button.center.dx, lessThan(screenCenter));
        }
        expect(
          button.bottom,
          lessThanOrEqualTo(tester.getTopLeft(find.byType(AppBottomNavBar)).dy),
        );

        await tester.tap(find.byType(ScrollToTopButton));
        await tester.pumpAndSettle();

        final position = tester
            .state<ScrollableState>(homePageScrollable)
            .position;
        expect(position.pixels, 0);
        expect(isShown(tester), isFalse);
        expectNoLayoutErrors(tester);
      });
    }
  });
}
