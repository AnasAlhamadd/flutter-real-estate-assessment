import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/layout_expectations.dart';
import '../../helpers/pump_widget.dart';
import '../../helpers/translations.dart';

const _spaced = TextStyle(fontSize: 12, letterSpacing: 1.2);

Text _textOf(WidgetTester tester) => tester.widget<Text>(
  find.descendant(of: find.byType(CustomText), matching: find.byType(Text)),
);

void main() {
  testWidgetsInLayouts('shows the translation of its key', (
    tester,
    locale,
    size,
    textScale,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.commonRetry),
      locale: locale,
      size: size,
      textScale: textScale,
    );

    expectNoLayoutErrors(tester);
    expect(find.text(translate(locale, 'common.retry')), findsOneWidget);
  });

  testWidgets('passes style, alignment, max lines and overflow to Text', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(
        AppTextKeys.commonEmpty,
        style: _spaced,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final text = _textOf(tester);
    expect(text.style, _spaced);
    expect(text.textAlign, TextAlign.center);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('upper-cases the translation when asked', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.splashTagline, upperCase: true),
    );

    expect(
      find.text(
        translate(AppLocalization.english, 'splash.tagline').toUpperCase(),
      ),
      findsOneWidget,
    );
  });

  testWidgets('keeps letter spacing in the English locale', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.splashTagline, style: _spaced),
    );

    expect(_textOf(tester).style?.letterSpacing, 1.2);
  });

  testWidgets('drops letter spacing in the Arabic locale', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.splashTagline, style: _spaced),
      locale: AppLocalization.arabic,
    );

    final style = _textOf(tester).style!;
    expect(style.letterSpacing, 0);
    expect(style.fontSize, _spaced.fontSize);
  });

  testWidgets('drops letter spacing for Latin text in the Arabic locale', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.appTitle, style: _spaced),
      locale: AppLocalization.arabic,
    );

    expect(_textOf(tester).style?.letterSpacing, 0);
  });

  group('CustomText.plain', () {
    testWidgetsInLayouts('shows its text as-is, without translating it', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const Column(
          children: [
            CustomText.plain('Calvin Klein CK One'),
            CustomText.plain(AppTextKeys.commonRetry),
          ],
        ),
        locale: locale,
        size: size,
        textScale: textScale,
      );

      expectNoLayoutErrors(tester);
      expect(find.text('Calvin Klein CK One'), findsOneWidget);
      expect(find.text(AppTextKeys.commonRetry), findsOneWidget);
      expect(find.text(translate(locale, 'common.retry')), findsNothing);
    });

    testWidgets('passes wrapping, direction and semantics to Text', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const CustomText.plain(
          r'$9.99',
          style: _spaced,
          softWrap: false,
          textDirection: TextDirection.ltr,
          semanticsLabel: '9.99 dollars',
        ),
      );

      final text = _textOf(tester);
      expect(text.style, _spaced);
      expect(text.softWrap, isFalse);
      expect(text.textDirection, TextDirection.ltr);
      expect(text.semanticsLabel, '9.99 dollars');
    });

    testWidgets('upper-cases plain text when asked', (tester) async {
      await pumpLocalizedWidget(
        tester,
        const CustomText.plain('real scout', upperCase: true),
      );

      expect(find.text('REAL SCOUT'), findsOneWidget);
    });

    testWidgets('ellipsizes text longer than its width without overflow', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const Center(
          child: SizedBox(
            width: 120,
            child: CustomText.plain(
              'A very long property title that cannot fit on one line',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      expectNoLayoutErrors(tester);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.byType(RichText),
      );
      expect(paragraph.didExceedMaxLines, isTrue);
      expect(
        tester.getSize(find.byType(RichText)).width,
        lessThanOrEqualTo(120),
      );
    });

    testWidgets("follows the user's text scale instead of overriding it", (
      tester,
    ) async {
      Future<Size> pumpAt(double scale) async {
        await pumpLocalizedWidget(
          tester,
          const Center(child: CustomText.plain('Featured')),
          textScale: scale,
        );
        return tester.getSize(find.byType(RichText));
      }

      final normal = await pumpAt(1);
      final large = await pumpAt(1.3);

      expect(_textOf(tester).textScaler, isNull);
      expect(
        tester.widget<RichText>(find.byType(RichText)).textScaler.scale(10),
        closeTo(13, 0.001),
      );
      expect(large.height, greaterThan(normal.height));
    });

    testWidgets('lays out right-to-left in Arabic unless told otherwise', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        const Column(
          children: [
            CustomText.plain('عقارات', key: Key('ambient')),
            CustomText.plain(
              r'$12219',
              key: Key('forced'),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
        locale: AppLocalization.arabic,
      );

      TextDirection directionOf(String key) => tester
          .renderObject<RenderParagraph>(
            find.descendant(
              of: find.byKey(Key(key)),
              matching: find.byType(RichText),
            ),
          )
          .textDirection;
      expect(directionOf('ambient'), TextDirection.rtl);
      expect(directionOf('forced'), TextDirection.ltr);
    });
  });

  testWidgets('rebuilds with the new language after a locale change', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const CustomText(AppTextKeys.commonRetry),
    );

    await tester
        .element(find.byType(CustomText))
        .setLocale(AppLocalization.arabic);
    await tester.pumpAndSettle();

    expect(
      find.text(translate(AppLocalization.arabic, 'common.retry')),
      findsOneWidget,
    );
  });
}
