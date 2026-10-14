import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_bottom_nav_bar.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_divider.dart';
import 'package:flutter_real_estate_assessment/core/widget/guest_avatar.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/pages/profile_screen.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/language_sheet.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/profile_menu_row.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/profile_finders.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/svg_finders.dart';
import '../../../../helpers/test_viewports.dart';
import '../../../../helpers/translations.dart';

const _en = AppLocalization.english;
const _ar = AppLocalization.arabic;

Finder _inProfile(Finder finder) =>
    find.descendant(of: find.byType(ProfileScreen), matching: finder);

Finder _title(Locale locale) =>
    _inProfile(find.text(translate(locale, 'profile.title')));

Finder _rowValue(Locale displayLocale, String languageKey) => find.descendant(
  of: find.byType(ProfileMenuRow),
  matching: find.text(translate(displayLocale, languageKey)),
);

Future<void> _pumpProfile(
  WidgetTester tester, {
  Locale locale = _en,
  TestViewport viewport = defaultViewport,
  double textScale = 1,
}) => pumpApp(
  tester,
  locale: locale,
  viewport: viewport,
  textScale: textScale,
  initialLocation: AppRouter.profile,
);

void main() {
  group('ProfileScreen layout', () {
    for (final locale in AppLocalization.supportedLocales) {
      testWidgets(
        'matches the Figma frame 1:3786 at 430×932 (${locale.languageCode})',
        (tester) async {
          await _pumpProfile(tester, locale: locale);

          // Figma y values minus the 44 status bar, below the 47 test inset.
          const top = 47.0 - 44;
          final title = tester.getRect(_title(locale));
          expect(title.center.dy, closeTo(top + 60 + 22, 0.5));

          final avatar = tester.getRect(find.byType(GuestAvatar));
          expect(avatar, const Rect.fromLTWH(145, top + 120, 140, 140));

          final name = tester.getRect(
            find.text(translate(locale, 'profile.guest_name')),
          );
          expect(name.top, top + 120 + 154);
          expect(name.center.dx, 215);

          final divider = tester.getRect(find.byType(AppDivider));
          expect(divider.top, closeTo(top + 120 + 207, 1));
          expect(divider.width, 390);

          final icon = tester.getRect(svgAsset(ImagePath.language));
          expect(icon.size, const Size.square(28));
          expect(icon.top, closeTo(top + 120 + 231, 1.5));
          final chevron = tester.getRect(svgAsset(ImagePath.arrowRight));
          expect(chevron.size, const Size.square(20));
          expect(chevron.center.dy, closeTo(icon.center.dy, 0.01));

          if (directionOf(locale) == TextDirection.ltr) {
            expect(title.left, 20);
            expect(icon.left, 20);
            expect(chevron.right, 410);
          } else {
            expect(title.right, 410);
            expect(icon.right, 410);
            expect(chevron.left, 20);
          }
        },
      );
    }

    testWidgets('shows only the Language row (Q17)', (tester) async {
      await _pumpProfile(tester);

      expect(find.byType(ProfileMenuRow), findsOneWidget);
      expect(
        _inProfile(find.text(translate(_en, 'language.title'))),
        findsOneWidget,
      );
      for (final hidden in [
        'My Booking',
        'Payments',
        'Notification',
        'Security',
        'Help Center',
        'Invite Friends',
        'Logout',
        'Adrian Hajdin',
      ]) {
        expect(find.text(hidden), findsNothing, reason: hidden);
      }
    });

    testWidgets('has no bell or edit badge', (tester) async {
      await _pumpProfile(tester);

      // Guest avatar icon, Language icon, chevron: nothing else.
      expect(_inProfile(find.byType(SvgPicture)), findsNWidgets(3));
      expect(_inProfile(svgAsset(ImagePath.profileLight)), findsOneWidget);
      expect(_inProfile(svgAsset(ImagePath.language)), findsOneWidget);
      expect(_inProfile(svgAsset(ImagePath.arrowRight)), findsOneWidget);
    });

    testWidgets('the title is announced as a header', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpProfile(tester);

      expect(tester.getSemantics(_title(_en)), isSemantics(isHeader: true));
      semantics.dispose();
    });

    for (final viewport in testViewports) {
      for (final locale in AppLocalization.supportedLocales) {
        for (final textScale in [1.0, 1.3]) {
          testWidgets(
            'lays out on $viewport · ${locale.languageCode} · x$textScale',
            (tester) async {
              await _pumpProfile(
                tester,
                locale: locale,
                viewport: viewport,
                textScale: textScale,
              );

              expectNoLayoutErrors(tester);
              expectDirectionFor(tester, locale);
              await tester.ensureVisible(find.byType(ProfileMenuRow));
              await tester.pumpAndSettle();
              expectVisibleAndTappable(tester, find.byType(ProfileMenuRow));

              await tester.tap(find.byType(ProfileMenuRow));
              await tester.pumpAndSettle();
              expectNoLayoutErrors(tester);
              expectVisibleAndTappable(
                tester,
                languageOption(locale, 'language.english'),
              );
              expectVisibleAndTappable(
                tester,
                languageOption(locale, 'language.arabic'),
              );
            },
          );
        }
      }
    }
  });

  group('ProfileScreen language row', () {
    testWidgets('shows the current language', (tester) async {
      await _pumpProfile(tester);
      expect(_rowValue(_en, 'language.english'), findsOneWidget);
    });

    testWidgets('shows the current language in Arabic', (tester) async {
      await _pumpProfile(tester, locale: _ar);
      expect(_rowValue(_ar, 'language.arabic'), findsOneWidget);
    });

    testWidgets('opens the sheet over the nav bar', (tester) async {
      await _pumpProfile(tester);

      await tester.tap(find.byType(ProfileMenuRow));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSheet), findsOneWidget);
      expect(find.byType(AppBottomNavBar).hitTestable(), findsNothing);
    });

    testWidgets('picking Arabic switches at once, flips and persists', (
      tester,
    ) async {
      await _pumpProfile(tester);

      await pickLanguageOnProfile(
        tester,
        from: _en,
        optionKey: 'language.arabic',
      );

      expectNoLayoutErrors(tester);
      expect(find.byType(LanguageSheet), findsNothing);
      expectDirectionFor(tester, _ar);
      expect(_title(_ar), findsOneWidget);
      expect(_rowValue(_ar, 'language.arabic'), findsOneWidget);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('locale'), 'ar');
    });

    testWidgets('picking the current language only closes the sheet', (
      tester,
    ) async {
      await _pumpProfile(tester);

      await pickLanguageOnProfile(
        tester,
        from: _en,
        optionKey: 'language.english',
      );

      expect(find.byType(LanguageSheet), findsNothing);
      expectDirectionFor(tester, _en);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('locale'), isNull);
    });

    testWidgets('dismissing the sheet keeps the language', (tester) async {
      await _pumpProfile(tester);

      await tester.tap(find.byType(ProfileMenuRow));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(215, 60));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSheet), findsNothing);
      expectDirectionFor(tester, _en);
      expect(_rowValue(_en, 'language.english'), findsOneWidget);
    });
  });
}
