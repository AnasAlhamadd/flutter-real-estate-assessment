import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/pages/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/layout_expectations.dart';
import '../helpers/profile_finders.dart';
import '../helpers/pump_app.dart';
import '../helpers/translations.dart';

Finder _profileTitle(Locale locale) => find.descendant(
  of: find.byType(ProfileScreen),
  matching: find.text(translate(locale, 'profile.title')),
);

void main() {
  const en = AppLocalization.english;
  const ar = AppLocalization.arabic;

  testWidgets('switching to Arabic flips direction instantly and persists', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: AppRouter.profile);
    expectDirectionFor(tester, en);

    await pickLanguageOnProfile(tester, from: en, optionKey: 'language.arabic');

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, ar);
    expect(_profileTitle(ar), findsOneWidget);
    expect(find.text(translate(ar, 'nav.home')), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('locale'), 'ar');
  });

  testWidgets('switching back to English restores LTR', (tester) async {
    await pumpApp(tester, locale: ar, initialLocation: AppRouter.profile);
    expectDirectionFor(tester, ar);

    await pickLanguageOnProfile(
      tester,
      from: ar,
      optionKey: 'language.english',
    );

    expectDirectionFor(tester, en);
    expect(_profileTitle(en), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('locale'), 'en');
  });

  testWidgets('a saved language is restored on the next launch', (
    tester,
  ) async {
    await pumpApp(tester, preferences: {'locale': 'ar'});

    expectDirectionFor(tester, ar);
    expect(find.text(translate(ar, 'home.featured')), findsOneWidget);
  });

  testWidgets('switching language updates Home without a restart', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text(translate(en, 'home.featured')), findsOneWidget);

    await tester.tap(find.text(translate(en, 'nav.profile')));
    await tester.pumpAndSettle();
    await pickLanguageOnProfile(tester, from: en, optionKey: 'language.arabic');
    await tester.tap(find.text(translate(ar, 'nav.home')));
    await tester.pumpAndSettle();

    expectNoLayoutErrors(tester);
    expectDirectionFor(tester, ar);
    expect(find.text(translate(ar, 'home.featured')), findsOneWidget);
    expect(find.text(translate(ar, 'home.welcome_guest')), findsOneWidget);
    expect(find.text(translate(en, 'home.featured')), findsNothing);
  });

  testWidgets('language switch keeps the current tab', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.profile);

    await pickLanguageOnProfile(tester, from: en, optionKey: 'language.arabic');

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(_profileTitle(ar), findsOneWidget);
  });
}
