import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_bottom_nav_bar.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/pages/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/layout_expectations.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_viewports.dart';
import '../helpers/translations.dart';

typedef _TabRoute = ({String path, String titleKey});

/// Tabs that are still placeholders.
const List<_TabRoute> _tabRoutes = [
  (path: AppRouter.explore, titleKey: 'explore.title'),
  (path: AppRouter.profile, titleKey: 'profile.title'),
];

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
/// `test/feature/properties/presentation/pages/home_screen_test.dart`.
void main() {
  for (final locale in AppLocalization.supportedLocales) {
    for (final viewport in testViewports) {
      for (final textScale in _textScales) {
        final variant = '$viewport · ${locale.languageCode} · x$textScale';

        for (final route in _tabRoutes) {
          testWidgets('${route.path} lays out on $variant', (tester) async {
            await pumpApp(
              tester,
              locale: locale,
              viewport: viewport,
              textScale: textScale,
              initialLocation: route.path,
            );

            expectNoLayoutErrors(tester);
            expectDirectionFor(tester, locale);
            expect(
              find.widgetWithText(AppBar, translate(locale, route.titleKey)),
              findsOneWidget,
            );
            expect(
              find.text(translate(locale, 'common.coming_soon')),
              findsOneWidget,
            );
            _expectNavInReach(tester, locale);
          });
        }

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
          expect(
            find.widgetWithText(AppBar, translate(locale, 'details.title')),
            findsOneWidget,
          );
          expectVisibleAndTappable(tester, find.byType(BackButton));

          await tester.tap(find.byType(BackButton));
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
    expect(
      find.widgetWithText(
        AppBar,
        translate(AppLocalization.english, 'explore.title'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.text(translate(AppLocalization.english, 'nav.profile')),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(
        AppBar,
        translate(AppLocalization.english, 'profile.title'),
      ),
      findsOneWidget,
    );
  });
}
