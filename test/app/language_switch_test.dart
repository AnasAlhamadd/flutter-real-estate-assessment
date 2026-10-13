import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/layout_expectations.dart';
import '../helpers/pump_app.dart';
import '../helpers/translations.dart';

void main() {
  const en = AppLocalization.english;
  const ar = AppLocalization.arabic;

  testWidgets('switching to Arabic flips direction instantly and persists', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: AppRouter.profile);
    expectDirectionFor(tester, en);

    await tester.tap(find.text(translate(en, 'language.arabic')));
    await tester.pumpAndSettle();

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, ar);
    expect(
      find.widgetWithText(AppBar, translate(ar, 'profile.title')),
      findsOneWidget,
    );
    expect(find.text(translate(ar, 'nav.home')), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('locale'), 'ar');
  });

  testWidgets('switching back to English restores LTR', (tester) async {
    await pumpApp(tester, locale: ar, initialLocation: AppRouter.profile);
    expectDirectionFor(tester, ar);

    await tester.tap(find.text(translate(ar, 'language.english')));
    await tester.pumpAndSettle();

    expectDirectionFor(tester, en);
    expect(
      find.widgetWithText(AppBar, translate(en, 'profile.title')),
      findsOneWidget,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('locale'), 'en');
  });

  testWidgets('a saved language is restored on the next launch', (
    tester,
  ) async {
    await pumpApp(tester, preferences: {'locale': 'ar'});

    expectDirectionFor(tester, ar);
    expect(
      find.widgetWithText(AppBar, translate(ar, 'home.title')),
      findsOneWidget,
    );
  });

  testWidgets('language switch keeps the current tab', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.profile);

    await tester.tap(find.text(translate(en, 'language.arabic')));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppBar, translate(ar, 'profile.title')),
      findsOneWidget,
    );
  });
}
