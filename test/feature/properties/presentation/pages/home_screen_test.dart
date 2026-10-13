import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_bottom_nav_bar.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_search_field.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/category_chip.dart';
import 'package:flutter_real_estate_assessment/core/widget/loading_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/section_header.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/featured_property_card.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_grid_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_properties_repository.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/test_viewports.dart';
import '../../../../helpers/translations.dart';

const Locale _en = AppLocalization.english;
const Locale _ar = AppLocalization.arabic;

/// Brief sizes plus a tablet and a phone in landscape.
const List<({TestViewport viewport, int columns})> _layouts = [
  (
    viewport: TestViewport(
      'compact phone',
      Size(320, 568),
      FakeViewPadding(top: 20),
    ),
    columns: 2,
  ),
  (
    viewport: TestViewport(
      'android phone',
      Size(360, 800),
      FakeViewPadding(top: 24, bottom: 16),
    ),
    columns: 2,
  ),
  (
    viewport: TestViewport(
      'large phone',
      Size(430, 932),
      FakeViewPadding(top: 47, bottom: 34),
    ),
    columns: 2,
  ),
  (
    viewport: TestViewport(
      'tablet portrait',
      Size(768, 1024),
      FakeViewPadding(top: 24, bottom: 20),
    ),
    columns: 3,
  ),
  (
    viewport: TestViewport(
      'phone landscape',
      Size(932, 430),
      FakeViewPadding(left: 47, right: 47, bottom: 21),
    ),
    columns: 3,
  ),
];

Finder get _pageScrollable => find
    .descendant(
      of: find.byType(HomeScreen),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    )
    .first;

Finder _gridCardTitled(String title) => find.descendant(
  of: find.byType(PropertyGridCard),
  matching: find.text(title),
);

Finder _chip(String label) => find.widgetWithText(CategoryChip, label);

Finder _featuredCardTitled(String title) => find.descendant(
  of: find.byType(FeaturedPropertyCard),
  matching: find.text(title),
);

Future<void> _scrollToEnd(WidgetTester tester) async {
  final position = tester.state<ScrollableState>(_pageScrollable).position;
  // Lazily built rows can extend the scroll range after each jump.
  for (var i = 0; i < 5; i++) {
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
  }
}

Future<void> _scrollIntoView(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _pageScrollable);
  await tester.pumpAndSettle();
}

void _expectExploreOpen(Locale locale) => expect(
  find.widgetWithText(AppBar, translate(locale, 'explore.title')),
  findsOneWidget,
);

void main() {
  group('responsive layout', () {
    for (final layout in _layouts) {
      for (final locale in AppLocalization.supportedLocales) {
        for (final textScale in const [1.0, 1.3]) {
          final variant =
              '${layout.viewport} · ${locale.languageCode} · x$textScale';

          testWidgets(
            'shows every Figma section without overflow on $variant',
            (tester) async {
              await pumpApp(
                tester,
                locale: locale,
                viewport: layout.viewport,
                textScale: textScale,
              );

              expectNoLayoutErrors(tester);
              expectDirectionFor(tester, locale);
              expect(
                find.text(translate(locale, 'home.welcome_guest')),
                findsOneWidget,
              );
              expect(
                find.text(translate(locale, 'common.search_hint')),
                findsOneWidget,
              );
              expect(
                find.text(translate(locale, 'home.featured')),
                findsOneWidget,
              );
              expect(find.byType(FeaturedPropertyCard), findsWidgets);

              final card = tester.getRect(
                find.byType(FeaturedPropertyCard).first,
              );
              final navTop = tester.getTopLeft(find.byType(AppBottomNavBar)).dy;
              expect(
                card.width / card.height,
                closeTo(
                  AppSizes.featuredCardWidth / AppSizes.featuredCardHeight,
                  0.01,
                ),
              );
              expect(
                card.height,
                lessThan(navTop - layout.viewport.padding.top),
                reason: 'a Featured card must fit in the visible area',
              );

              await _scrollIntoView(
                tester,
                find.text(translate(locale, 'home.recommendation')),
              );
              expect(
                find.text(translate(locale, 'common.all')),
                findsOneWidget,
              );

              final firstGridCard = _gridCardTitled(
                sampleProperties.first.title,
              );
              await _scrollIntoView(tester, firstGridCard);
              final firstRowTop = tester.getRect(firstGridCard).top;
              final columns = sampleProperties
                  .map((property) => _gridCardTitled(property.title))
                  .where(
                    (title) =>
                        title.evaluate().isNotEmpty &&
                        tester.getRect(title).top == firstRowTop,
                  )
                  .length;
              expect(columns, layout.columns);

              await _scrollToEnd(tester);
              expectNoLayoutErrors(tester);
              final lastCard = tester.getRect(
                find.ancestor(
                  of: _gridCardTitled(sampleProperties.last.title),
                  matching: find.byType(PropertyGridCard),
                ),
              );
              expect(lastCard.bottom, lessThanOrEqualTo(navTop));
            },
          );
        }
      }
    }

    testWidgets('matches the Figma geometry at the 430×932 design size', (
      tester,
    ) async {
      await pumpApp(tester);

      final screenWidth = AppSizes.designSize.width;
      final search = tester.getRect(find.byType(AppSearchField));
      expect(search.left, 20);
      expect(search.width, screenWidth - 40);
      expect(search.height, 52);

      final featured = tester.getRect(find.byType(FeaturedPropertyCard).first);
      expect(featured.size, const Size(250, 340));
      expect(featured.left, 20);
      final second = tester.getRect(find.byType(FeaturedPropertyCard).at(1));
      expect(second.left - featured.right, 20);
    });

    testWidgets('long API text stays inside its cards on the smallest phone', (
      tester,
    ) async {
      final long = [
        for (var id = 1; id <= 4; id++)
          PropertyEntity(
            id: id,
            title: 'Very Long Luxury Penthouse Apartment With Sea View $id' * 3,
            price: 1234567.89,
            rating: 5,
            category: 'home-decoration',
            brand: 'An Exceptionally Long Brand Name Used As Location ' * 2,
          ),
      ];
      await pumpApp(
        tester,
        locale: _ar,
        viewport: _layouts.first.viewport,
        textScale: 1.3,
        repository: FakePropertiesRepository(
          featured: Right(long),
          firstPage: Right(pageOf(long)),
        ),
      );

      expectNoLayoutErrors(tester);
      await _scrollToEnd(tester);
      expectNoLayoutErrors(tester);
    });
  });

  group('direction', () {
    testWidgets(
      'Arabic starts the Featured row and the header from the right',
      (tester) async {
        await pumpApp(tester, locale: _ar);

        final width = AppSizes.designSize.width;
        final firstCard = tester.getRect(
          find.byType(FeaturedPropertyCard).first,
        );
        expect(firstCard.right, closeTo(width - 20, 0.01));

        final title = tester.getCenter(
          find.text(translate(_ar, 'home.featured')),
        );
        final seeAll = tester.getCenter(
          find.text(translate(_ar, 'common.see_all')).first,
        );
        expect(seeAll.dx, lessThan(title.dx));

        final welcome = tester.getTopRight(
          find.text(translate(_ar, 'home.welcome_guest')),
        );
        expect(welcome.dx, lessThan(width - 20 - 44));
      },
    );

    testWidgets('English starts the Featured row from the left', (
      tester,
    ) async {
      await pumpApp(tester);

      final firstCard = tester.getRect(find.byType(FeaturedPropertyCard).first);
      expect(firstCard.left, closeTo(20, 0.01));
    });
  });

  group('content', () {
    testWidgets('shows API data in the cards and the API categories as chips', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(_featuredCardTitled(sampleProperties.first.title), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FeaturedPropertyCard).first,
          matching: find.text(r'$9.99'),
        ),
        findsOneWidget,
      );
      await _scrollIntoView(tester, _chip('Furniture'));
      for (final category in sampleCategories) {
        expect(_chip(category.name), findsOneWidget);
      }
    });

    testWidgets('hides the filter button until the Filter sheet exists', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppSvgIcon && widget.assetPath == ImagePath.filter,
        ),
        findsNothing,
      );
    });
  });

  group('navigation', () {
    testWidgets('the search bar opens Explore', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byType(AppSearchField));
      await tester.pumpAndSettle();

      _expectExploreOpen(_en);
    });

    for (final titleKey in const ['home.featured', 'home.recommendation']) {
      testWidgets('"See All" of $titleKey opens Explore', (tester) async {
        await pumpApp(tester);
        final seeAll = find.descendant(
          of: find.widgetWithText(SectionHeader, translate(_en, titleKey)),
          matching: find.text(translate(_en, 'common.see_all')),
        );
        await _scrollIntoView(tester, seeAll);

        await tester.tap(seeAll);
        await tester.pumpAndSettle();

        _expectExploreOpen(_en);
      });
    }

    testWidgets('a Featured card opens its details and Back returns Home', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(_featuredCardTitled(sampleProperties.first.title));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(AppBar, translate(_en, 'details.title')),
        findsOneWidget,
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('a recommendation card opens its details', (tester) async {
      await pumpApp(tester);
      final card = _gridCardTitled(sampleProperties[1].title);
      await _scrollIntoView(tester, card);

      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AppBar, translate(_en, 'details.title')),
        findsOneWidget,
      );
    });

    testWidgets('a category chip reloads the grid for that category', (
      tester,
    ) async {
      final furniture = sampleProperties
          .where((property) => property.category == 'furniture')
          .toList();
      await pumpApp(
        tester,
        repository: FakePropertiesRepository(
          categoryPages: {'furniture': Right(pageOf(furniture))},
        ),
      );
      await _scrollIntoView(tester, _chip('Furniture'));

      await tester.tap(_chip('Furniture'));
      await tester.pumpAndSettle();
      await _scrollToEnd(tester);

      expect(find.byType(PropertyGridCard), findsNWidgets(furniture.length));
      expect(_gridCardTitled(sampleProperties.first.title), findsNothing);
    });
  });

  group('section states', () {
    testWidgets('a Featured failure shows a retry that recovers', (
      tester,
    ) async {
      final repository = FakePropertiesRepository(
        featured: const Left(NetworkFailure()),
      );
      await pumpApp(tester, repository: repository);

      expect(find.text(translate(_en, 'errors.no_internet')), findsOneWidget);
      expect(find.byType(FeaturedPropertyCard), findsNothing);
      expect(
        find.text(translate(_en, 'home.recommendation')),
        findsOneWidget,
        reason: 'the other sections stay on screen',
      );

      repository.featured = const Right(sampleProperties);
      await tester.tap(find.text(translate(_en, 'common.retry')));
      await tester.pumpAndSettle();

      expect(find.text(translate(_en, 'errors.no_internet')), findsNothing);
      expect(find.byType(FeaturedPropertyCard), findsWidgets);
    });

    testWidgets('a recommendations failure shows a retry that recovers', (
      tester,
    ) async {
      final repository = FakePropertiesRepository(
        firstPage: const Left(ServerFailure(statusCode: 500)),
      );
      await pumpApp(tester, repository: repository);
      final message = find.text(translate(_en, 'errors.server'));
      await _scrollIntoView(tester, message);
      expect(find.byType(FeaturedPropertyCard), findsWidgets);

      repository.firstPage = Right(pageOf(sampleProperties));
      final retry = find.text(translate(_en, 'common.retry'));
      await _scrollIntoView(tester, retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();

      expect(message, findsNothing);
      expect(find.byType(PropertyGridCard), findsWidgets);
    });

    testWidgets('saved results show the offline notice', (tester) async {
      await pumpApp(
        tester,
        locale: _ar,
        repository: FakePropertiesRepository(
          firstPage: Right(pageOf(sampleProperties, isFromCache: true)),
        ),
      );
      final notice = find.text(translate(_ar, 'common.offline_saved_data'));

      await _scrollIntoView(tester, notice);

      expect(notice, findsOneWidget);
    });

    testWidgets('empty sections show the empty message', (tester) async {
      await pumpApp(
        tester,
        repository: FakePropertiesRepository(
          featured: const Right([]),
          firstPage: Right(pageOf(const [])),
        ),
      );
      await _scrollToEnd(tester);

      expect(find.text(translate(_en, 'common.empty')), findsNWidgets(2));
      expectNoLayoutErrors(tester);
    });

    testWidgets('shows a loading indicator per section while data loads', (
      tester,
    ) async {
      final gate = Completer<void>();
      final repository = FakePropertiesRepository()..gate = gate.future;

      await pumpLocalizedWidget(
        tester,
        BlocProvider<HomeCubit>(
          create: (_) => homeCubitFor(repository)..load(),
          child: HomeView(clock: () => DateTime(2026, 10, 13, 9)),
        ),
        settle: false,
      );

      expect(find.byType(LoadingView), findsNWidgets(2));
      expectNoLayoutErrors(tester);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LoadingView), findsNothing);
      expect(find.byType(FeaturedPropertyCard), findsWidgets);
    });
  });

  testWidgets('greets with the time of day from the clock', (tester) async {
    await pumpLocalizedWidget(
      tester,
      BlocProvider<HomeCubit>(
        create: (_) => homeCubitFor(FakePropertiesRepository())..load(),
        child: HomeView(clock: () => DateTime(2026, 10, 13, 18)),
      ),
      locale: _ar,
    );

    expect(find.text(translate(_ar, 'home.good_evening')), findsOneWidget);
  });
}
