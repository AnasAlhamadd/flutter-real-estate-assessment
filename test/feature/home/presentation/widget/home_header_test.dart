import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/home_header.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/translations.dart';

DateTime _at(int hour) => DateTime(2026, 10, 13, hour);

void main() {
  group('HomeHeader', () {
    test('greets by time of day', () {
      expect(HomeHeader.greetingKeyFor(_at(5)), AppTextKeys.homeGoodMorning);
      expect(HomeHeader.greetingKeyFor(_at(11)), AppTextKeys.homeGoodMorning);
      expect(HomeHeader.greetingKeyFor(_at(12)), AppTextKeys.homeGoodAfternoon);
      expect(HomeHeader.greetingKeyFor(_at(16)), AppTextKeys.homeGoodAfternoon);
      expect(HomeHeader.greetingKeyFor(_at(17)), AppTextKeys.homeGoodEvening);
      expect(HomeHeader.greetingKeyFor(_at(0)), AppTextKeys.homeGoodEvening);
      expect(HomeHeader.greetingKeyFor(_at(4)), AppTextKeys.homeGoodEvening);
    });

    testWidgetsInLayouts('shows the greeting and the guest welcome line', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        Padding(
          padding: const EdgeInsets.all(20),
          child: HomeHeader(now: _at(9)),
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(find.text(translate(locale, 'home.good_morning')), findsOneWidget);
      expect(
        find.text(translate(locale, 'home.welcome_guest')),
        findsOneWidget,
      );
    });

    testWidgetsInLayouts('puts the avatar on the reading-start side', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        HomeHeader(now: _at(20)),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      final avatar = tester.getCenter(find.byType(ExcludeSemantics).last);
      final greeting = tester.getCenter(
        find.text(translate(locale, 'home.good_evening')),
      );
      if (directionOf(locale) == TextDirection.ltr) {
        expect(avatar.dx, lessThan(greeting.dx));
      } else {
        expect(avatar.dx, greaterThan(greeting.dx));
      }
    });

    testWidgets('keeps a 44×44 avatar at the design size', (tester) async {
      await pumpLocalizedWidget(tester, HomeHeader(now: _at(9)));

      final avatar = find.descendant(
        of: find.byType(HomeHeader),
        matching: find.byType(Container),
      );
      expect(tester.getSize(avatar), const Size(44, 44));
    });
  });
}
