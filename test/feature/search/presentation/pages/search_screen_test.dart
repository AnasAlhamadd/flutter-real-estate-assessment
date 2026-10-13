import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_search_field.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/load_more_error_view.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_card_skeletons.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/property_list_card.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/pages/property_details_screen.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_results_entity.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_header.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_results_count.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_search_repository.dart';
import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/sample_properties.dart';
import '../../../../helpers/test_viewports.dart';
import '../../../../helpers/translations.dart';

const Locale _en = AppLocalization.english;
const Locale _ar = AppLocalization.arabic;

Future<void> _pumpExplore(
  WidgetTester tester, {
  FakeSearchRepository? search,
  Locale locale = _en,
  TestViewport viewport = defaultViewport,
  double textScale = 1,
}) => pumpApp(
  tester,
  initialLocation: AppRouter.explore,
  search: search,
  locale: locale,
  viewport: viewport,
  textScale: textScale,
);

/// Types [text] and waits for the debounce, without settling (a skeleton's
/// shimmer never settles).
Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(SearchCubit.defaultDebounce);
  await tester.pump();
}

/// "Found {n}" in [locale], with the CLDR plural form for [count].
String _found(Locale locale, int count) {
  final form = switch ((locale.languageCode, count % 100)) {
    (_, _) when count == 1 => 'one',
    ('ar', _) when count == 0 => 'zero',
    ('ar', _) when count == 2 => 'two',
    ('ar', >= 3 && <= 10) => 'few',
    ('ar', >= 11) => 'many',
    _ => 'other',
  };
  return translate(locale, 'search.found.$form').replaceAll('{}', '$count');
}

SearchResultsEntity _results(
  String query,
  List<PropertyEntity> items, {
  int? total,
  bool hasReachedMax = true,
}) => SearchResultsEntity(
  query: query,
  items: items,
  total: total ?? items.length,
  hasReachedMax: hasReachedMax,
);

Rect _rectOf(WidgetTester tester, Finder finder) =>
    tester.getRect(finder.first);

void main() {
  group('Figma layout (430 × 932)', () {
    testWidgets('stacks header, search field, count and list with the '
        'Figma gaps', (tester) async {
      await _pumpExplore(tester);

      final header = _rectOf(tester, find.byType(SearchHeader));
      final back = _rectOf(tester, find.byType(AppBackButton));
      final field = _rectOf(tester, find.byType(AppSearchField));
      final count = _rectOf(tester, find.byType(SearchResultsCount));
      final firstCard = tester.getRect(find.byType(PropertyListCard).at(0));
      final secondCard = tester.getRect(find.byType(PropertyListCard).at(1));
      const topInset = 47;

      expect(back.topLeft, const Offset(20, topInset + 16));
      expect(back.size, const Size(44, 44));
      expect(field.top, closeTo(header.bottom + 24, 0.01));
      expect(field.left, 20);
      expect(field.width, 390);
      expect(field.height, greaterThanOrEqualTo(52));
      expect(count.top, closeTo(field.bottom + 24, 0.01));
      expect(firstCard.top, closeTo(count.bottom + 24, 0.01));
      expect(firstCard.left, 20);
      expect(firstCard.width, 390);
      expect(firstCard.height, greaterThanOrEqualTo(128));
      expect(secondCard.top, closeTo(firstCard.bottom + 16, 0.01));
    });

    testWidgets('centers the title between the back button and the hidden '
        'bell slot', (tester) async {
      await _pumpExplore(tester);

      final title = find.text(translate(_en, 'explore.title'));
      expect(title, findsOneWidget);
      expect(tester.getRect(title).center.dx, closeTo(215, 0.01));
    });

    testWidgets('has no filter icon until the Filter task', (tester) async {
      await _pumpExplore(tester);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppSvgIcon && widget.assetPath == ImagePath.filter,
        ),
        findsNothing,
      );
    });

    testWidgets('puts the back button on the start side in Arabic', (
      tester,
    ) async {
      await _pumpExplore(tester, locale: _ar);

      expect(_rectOf(tester, find.byType(AppBackButton)).right, 430 - 20);
      expect(find.text(translate(_ar, 'explore.title')), findsOneWidget);
    });
  });

  group('responsive layout', () {
    for (final viewport in testViewports) {
      for (final locale in AppLocalization.supportedLocales) {
        for (final textScale in const [1.0, 1.3]) {
          testWidgets('lays out without overflow on $viewport · '
              '${locale.languageCode} · x$textScale', (tester) async {
            await _pumpExplore(
              tester,
              locale: locale,
              viewport: viewport,
              textScale: textScale,
            );

            expectNoLayoutErrors(tester);
            expectDirectionFor(tester, locale);
            expectVisibleAndTappable(tester, find.byType(AppBackButton));
            expectVisibleAndTappable(tester, find.byType(TextField));
            expect(
              find.text(_found(locale, sampleProperties.length)),
              findsOneWidget,
            );
          });
        }
      }
    }
  });

  group('search', () {
    testWidgets('shows the "All" listing before a query', (tester) async {
      final search = FakeSearchRepository();
      await _pumpExplore(tester, search: search);

      expect(find.text(_found(_en, sampleProperties.length)), findsOneWidget);
      expect(find.text(sampleProperties.first.title), findsOneWidget);
      expect(search.requests, isEmpty);
    });

    testWidgets('one character sends no request', (tester) async {
      final search = FakeSearchRepository();
      await _pumpExplore(tester, search: search);

      await _type(tester, 'c');

      expect(search.requests, isEmpty);
      expect(find.text(_found(_en, sampleProperties.length)), findsOneWidget);
    });

    testWidgets('two characters search after the debounce and show the '
        'matches', (tester) async {
      final search = FakeSearchRepository();
      await _pumpExplore(tester, search: search);

      await tester.enterText(find.byType(TextField), 'mirror');
      await tester.pump(
        SearchCubit.defaultDebounce - const Duration(milliseconds: 1),
      );
      expect(search.requests, isEmpty);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(search.requests, ['first:mirror']);
      expect(find.text(_found(_en, 2)), findsOneWidget);
      expect(find.byType(PropertyListCard), findsNWidgets(2));
      expect(find.text('Calvin Klein CK One'), findsNothing);
    });

    testWidgets('shows skeleton cards while the first page loads', (
      tester,
    ) async {
      final gate = Completer<void>();
      final search = FakeSearchRepository()..gate = gate.future;
      await _pumpExplore(tester, search: search);

      await _type(tester, 'mirror');

      expect(find.byType(PropertyListCardSkeleton), findsWidgets);
      expect(find.byType(PropertyListCard), findsNothing);
      expect(find.byType(SearchResultsCount), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(PropertyListCardSkeleton), findsNothing);
      expect(find.byType(PropertyListCard), findsNWidgets(2));
    });

    testWidgets('a successful empty search shows the no-results message', (
      tester,
    ) async {
      await _pumpExplore(tester);

      await _type(tester, 'zzz');
      await tester.pumpAndSettle();

      expect(find.text(translate(_en, 'search.no_results')), findsOneWidget);
      expect(find.byType(SearchResultsCount), findsNothing);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('a failed search shows the error and retries', (tester) async {
      final search = FakeSearchRepository(
        firstPages: {'bed': const Left(NetworkFailure())},
      );
      await _pumpExplore(tester, search: search);

      await _type(tester, 'bed');
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text(translate(_en, 'errors.no_internet')), findsOneWidget);
      expect(find.text(translate(_en, 'search.no_results')), findsNothing);

      search.firstPages = {};
      await tester.tap(find.text(translate(_en, 'common.retry')));
      await tester.pumpAndSettle();

      expect(search.requests, ['first:bed', 'first:bed']);
      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Annibale Colombo Bed'), findsOneWidget);
    });

    testWidgets('clearing the query returns to the "All" listing', (
      tester,
    ) async {
      await _pumpExplore(tester);
      await _type(tester, 'mirror');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text(_found(_en, sampleProperties.length)), findsOneWidget);
    });
  });

  group('pagination', () {
    final firstPage = _results(
      'ca',
      [sampleProperties.first],
      total: 2,
      hasReachedMax: false,
    );
    final allPages = _results('ca', [
      sampleProperties.first,
      sampleProperties.last,
    ]);

    testWidgets('shows a skeleton card while the next page loads', (
      tester,
    ) async {
      final gate = Completer<void>();
      final search = FakeSearchRepository(
        firstPages: {'ca': Right(firstPage)},
        nextPages: {'ca': Right(allPages)},
      )..nextPageGate = gate.future;
      await _pumpExplore(tester, search: search);

      await _type(tester, 'ca');
      await tester.pump();

      expect(search.requests, ['first:ca', 'next:ca']);
      expect(find.byType(PropertyListCard), findsOneWidget);
      expect(find.byType(PropertyListCardSkeleton), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(PropertyListCardSkeleton), findsNothing);
      expect(find.byType(PropertyListCard), findsNWidgets(2));
      expect(find.text(_found(_en, 2)), findsOneWidget);
      expect(search.requests, ['first:ca', 'next:ca']);
    });

    testWidgets('a failed next page keeps the results and offers a retry', (
      tester,
    ) async {
      final search = FakeSearchRepository(
        firstPages: {'ca': Right(firstPage)},
        nextPages: {'ca': const Left(ServerFailure(statusCode: 500))},
      );
      await _pumpExplore(tester, search: search);

      await _type(tester, 'ca');
      await tester.pumpAndSettle();

      expect(find.byType(PropertyListCard), findsOneWidget);
      expect(find.byType(LoadMoreErrorView), findsOneWidget);

      search.nextPages = {'ca': Right(allPages)};
      await tester.tap(
        find.descendant(
          of: find.byType(LoadMoreErrorView),
          matching: find.text(translate(_en, 'common.retry')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoadMoreErrorView), findsNothing);
      expect(find.byType(PropertyListCard), findsNWidgets(2));
    });
  });

  group('navigation and favorites', () {
    testWidgets('a result opens its details, and Back keeps the query and '
        'results', (tester) async {
      final search = FakeSearchRepository();
      await _pumpExplore(tester, search: search);
      await _type(tester, 'mirror');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eyeshadow Palette with Mirror'));
      await tester.pumpAndSettle();
      expect(find.byType(PropertyDetailsScreen), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(PropertyDetailsScreen),
          matching: find.byType(AppBackButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PropertyDetailsScreen), findsNothing);
      expect(find.widgetWithText(TextField, 'mirror'), findsOneWidget);
      expect(find.byType(PropertyListCard), findsNWidgets(2));
      expect(search.requests, ['first:mirror']);
    });

    testWidgets('the back button opens Home', (tester) async {
      await _pumpExplore(tester);

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('the heart saves the property as a favorite', (tester) async {
      await _pumpExplore(tester);
      final firstHeart = find
          .descendant(
            of: find.byType(PropertyListCard).first,
            matching: find.byType(FavoriteButton),
          )
          .first;
      expect(tester.widget<FavoriteButton>(firstHeart).isFavorite, isFalse);

      await tester.tap(firstHeart);
      await tester.pumpAndSettle();

      expect(tester.widget<FavoriteButton>(firstHeart).isFavorite, isTrue);
      expect(
        tester.widget<FavoriteButton>(firstHeart).variant,
        FavoriteButtonVariant.listCard,
      );
    });
  });
}
