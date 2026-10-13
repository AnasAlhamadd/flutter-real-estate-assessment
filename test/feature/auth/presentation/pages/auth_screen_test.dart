import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/pages/auth_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_viewports.dart';
import '../../../../helpers/translations.dart';

final List<TestViewport> _viewports = testViewports
    .where((viewport) => const [320.0, 430.0].contains(viewport.size.width))
    .toList();

const Locale _en = AppLocalization.english;

String _headline(Locale locale) =>
    '${translate(locale, 'auth.headline')} '
    '${translate(locale, 'auth.headline_highlight')}';

Finder _googleLabel(Locale locale) =>
    find.text(translate(locale, 'auth.google_button'));

Finder _guestLabel(Locale locale) =>
    find.text(translate(locale, 'auth.continue_as_guest'));

Finder _unavailableMessage(Locale locale) =>
    find.text(translate(locale, 'auth.sign_in_unavailable'));

Finder _homeTitle() =>
    find.widgetWithText(AppBar, translate(_en, 'home.title'));

String _location(WidgetTester tester) => GoRouter.of(
  tester.element(find.byType(Scaffold).first),
).routerDelegate.currentConfiguration.uri.path;

double _maxScrollExtent(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byType(AuthScreen),
        matching: find.byType(Scrollable),
      ),
    )
    .position
    .maxScrollExtent;

void main() {
  for (final locale in AppLocalization.supportedLocales) {
    for (final viewport in _viewports) {
      for (final textScale in const [1.0, 1.3]) {
        testWidgets('shows the Figma content with both actions in reach on '
            '$viewport · ${locale.languageCode} · x$textScale', (tester) async {
          await pumpApp(
            tester,
            locale: locale,
            viewport: viewport,
            textScale: textScale,
            initialLocation: AppRouter.auth,
          );

          expectNoLayoutErrors(tester);
          expectDirectionFor(tester, locale);
          expect(
            find.image(const AssetImage(ImagePath.authCollage)),
            findsOneWidget,
          );
          expect(
            find.text(translate(locale, 'auth.welcome').toUpperCase()),
            findsOneWidget,
          );
          expect(find.text(_headline(locale)), findsOneWidget);
          expect(find.text(translate(locale, 'auth.subtitle')), findsOneWidget);
          // Compact phones with large text scroll the panel (see below).
          for (final action in [_googleLabel(locale), _guestLabel(locale)]) {
            await tester.ensureVisible(action);
            await tester.pumpAndSettle();
            expectVisibleAndTappable(tester, action);
          }
        });
      }
    }
  }

  testWidgets('fits the design size without scrolling', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.auth);

    expect(_maxScrollExtent(tester), 0);
  });

  testWidgets('scrolls instead of overflowing when the text is very large', (
    tester,
  ) async {
    await pumpApp(
      tester,
      viewport: testViewports.first,
      textScale: 2,
      initialLocation: AppRouter.auth,
    );

    expectNoLayoutErrors(tester);
    expect(_maxScrollExtent(tester), greaterThan(0));

    await tester.ensureVisible(_guestLabel(_en));
    await tester.pumpAndSettle();
    expectVisibleAndTappable(tester, _guestLabel(_en));
  });

  for (final locale in AppLocalization.supportedLocales) {
    testWidgets('the Google button explains that sign-in is unavailable and '
        'stays on Auth (${locale.languageCode})', (tester) async {
      await pumpApp(tester, locale: locale, initialLocation: AppRouter.auth);

      await tester.tap(_googleLabel(locale));
      await tester.pumpAndSettle();

      expect(_unavailableMessage(locale), findsOneWidget);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(_location(tester), AppRouter.auth);
    });
  }

  testWidgets('repeated Google taps show a single message', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.auth);

    await tester.tap(_googleLabel(_en));
    await tester.pump();
    await tester.tap(_googleLabel(_en));
    await tester.pumpAndSettle();

    expect(_unavailableMessage(_en), findsOneWidget);
  });

  testWidgets('Continue as guest opens Home and replaces Auth', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.auth);

    await tester.tap(_guestLabel(_en));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsNothing);
    expect(_homeTitle(), findsOneWidget);
    expect(GoRouter.of(tester.element(_homeTitle())).canPop(), isFalse);
  });

  testWidgets('Continue as guest drops a pending sign-in message', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: AppRouter.auth);

    await tester.tap(_googleLabel(_en));
    await tester.pump();
    await tester.tap(_guestLabel(_en));
    await tester.pumpAndSettle();

    expect(_unavailableMessage(_en), findsNothing);
    expect(_homeTitle(), findsOneWidget);
  });

  testWidgets('exposes buttons and the headline to screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, initialLocation: AppRouter.auth);

    expect(
      tester.getSemantics(find.byType(OutlinedButton)),
      isSemantics(
        isButton: true,
        hasTapAction: true,
        label: translate(_en, 'auth.google_button'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(TextButton)),
      isSemantics(
        isButton: true,
        hasTapAction: true,
        label: translate(_en, 'auth.continue_as_guest'),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel(_headline(_en))),
      isSemantics(isHeader: true),
    );
    semantics.dispose();
  });
}
