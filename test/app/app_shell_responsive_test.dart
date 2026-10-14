import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_bottom_nav_bar.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/pages/profile_screen.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/pages/property_details_screen.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/pages/search_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/layout_expectations.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_viewports.dart';
import '../helpers/translations.dart';

const List<String> _navKeys = ['nav.home', 'nav.explore', 'nav.profile'];

const List<double> _textScales = [1, 1.3];

void _expectNavInReach(WidgetTester tester, Locale locale) {
  for (final key in _navKeys) {
    expectVisibleAndTappable(
      tester,
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text(translate(locale, key)),
      ),
    );
  }
}

/// The router shell on every viewport. Home has its own matrix in
/// `test/feature/home/presentation/pages/home_screen_test.dart`.
void main() {
  for (final locale in AppLocalization.supportedLocales) {
    for (final viewport in testViewports) {
      for (final textScale in _textScales) {
        final variant = '$viewport · ${locale.languageCode} · x$textScale';

        testWidgets('/ shows Home inside the shell on $variant', (
          tester,
        ) async {
          await pumpApp(
            tester,
            locale: locale,
            viewport: viewport,
            textScale: textScale,
          );

          expectNoLayoutErrors(tester);
          expectDirectionFor(tester, locale);
          expect(find.byType(HomeScreen), findsOneWidget);
          _expectNavInReach(tester, locale);
        });

        testWidgets('/explore shows Explore inside the shell on $variant', (
          tester,
        ) async {
          await pumpApp(
            tester,
            locale: locale,
            viewport: viewport,
            textScale: textScale,
            initialLocation: AppRouter.explore,
          );

          expectNoLayoutErrors(tester);
          expectDirectionFor(tester, locale);
          expect(find.byType(SearchScreen), findsOneWidget);
          _expectNavInReach(tester, locale);
        });

        testWidgets('/profile shows Profile inside the shell on $variant', (
          tester,
        ) async {
          await pumpApp(
            tester,
            locale: locale,
            viewport: viewport,
            textScale: textScale,
            initialLocation: AppRouter.profile,
          );

          expectNoLayoutErrors(tester);
          expectDirectionFor(tester, locale);
          expect(find.byType(ProfileScreen), findsOneWidget);
          _expectNavInReach(tester, locale);
        });

        testWidgets('details route shows a working back button on $variant', (
          tester,
        ) async {
          await pumpApp(
            tester,
            locale: locale,
            viewport: viewport,
            textScale: textScale,
          );
          GoRouter.of(
            tester.element(find.byType(AppBottomNavBar)),
          ).push(AppRouter.propertyDetailsPath(1));
          await tester.pumpAndSettle();

          expectNoLayoutErrors(tester);
          expectDirectionFor(tester, locale);
          expect(find.byType(PropertyDetailsScreen), findsOneWidget);
          expectVisibleAndTappable(tester, find.byType(AppBackButton));

          await tester.tap(find.byType(AppBackButton));
          await tester.pumpAndSettle();
          expect(find.byType(HomeScreen), findsOneWidget);
        });
      }
    }
  }

  testWidgets('unknown routes show a translated not-found message', (
    tester,
  ) async {
    await pumpApp(
      tester,
      locale: AppLocalization.arabic,
      initialLocation: '/does-not-exist',
    );

    expectNoLayoutErrors(tester);
    expect(
      find.text(translate(AppLocalization.arabic, 'errors.page_not_found')),
      findsOneWidget,
    );
  });

  testWidgets('bottom navigation switches tabs', (tester) async {
    await pumpApp(tester);

    await tester.tap(
      find.text(translate(AppLocalization.english, 'nav.explore')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    await tester.tap(
      find.text(translate(AppLocalization.english, 'nav.profile')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
