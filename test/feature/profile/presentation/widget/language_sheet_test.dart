import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/language_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/profile_finders.dart';
import '../../../../helpers/pump_widget.dart';
import '../../../../helpers/svg_finders.dart';
import '../../../../helpers/translations.dart';

const _en = AppLocalization.english;
const _ar = AppLocalization.arabic;

/// A button that opens the sheet and records what it completes with.
class _Opener extends StatelessWidget {
  const _Opener({required this.results});

  final List<Locale?> results;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () async => results.add(await showLanguageSheet(context)),
      child: const Text('open'),
    ),
  );
}

Future<List<Locale?>> _open(
  WidgetTester tester, {
  Locale locale = _en,
  Size size = const Size(430, 932),
  double textScale = 1,
}) async {
  final results = <Locale?>[];
  await pumpLocalizedWidget(
    tester,
    _Opener(results: results),
    locale: locale,
    size: size,
    textScale: textScale,
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

void main() {
  group('LanguageSheet', () {
    test('names each supported language with its own key', () {
      expect(LanguageSheet.nameKeyFor(_en), AppTextKeys.languageEnglish);
      expect(LanguageSheet.nameKeyFor(_ar), AppTextKeys.languageArabic);
    });

    testWidgetsInLayouts('shows the title and both languages', (
      tester,
      locale,
      size,
      textScale,
    ) async {
      await _open(tester, locale: locale, size: size, textScale: textScale);

      expectNoLayoutErrors(tester);
      expect(
        find.descendant(
          of: find.byType(LanguageSheet),
          matching: find.text(translate(locale, 'language.title')),
        ),
        findsOneWidget,
      );
      expect(languageOption(locale, 'language.english'), findsOneWidget);
      expect(languageOption(locale, 'language.arabic'), findsOneWidget);
    });

    for (final (locale, selectedKey, otherKey) in [
      (_en, 'language.english', 'language.arabic'),
      (_ar, 'language.arabic', 'language.english'),
    ]) {
      testWidgets('checks the current language (${locale.languageCode})', (
        tester,
      ) async {
        await _open(tester, locale: locale);

        expect(svgAsset(ImagePath.check), findsOneWidget);
        final check = tester.getCenter(svgAsset(ImagePath.check));
        final selected = tester.getCenter(languageOption(locale, selectedKey));
        final other = tester.getCenter(languageOption(locale, otherKey));
        expect(check.dy, closeTo(selected.dy, 1));
        expect((check.dy - other.dy).abs(), greaterThan(10));
        expect(
          tester.widget<Text>(languageOption(locale, selectedKey)).style?.color,
          ColorsApp.primary,
        );
        expect(
          tester.widget<Text>(languageOption(locale, otherKey)).style?.color,
          ColorsApp.black01,
        );
      });
    }

    testWidgets('announces the options as a single-choice group', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _open(tester);

      expect(
        tester.getSemantics(languageOption(_en, 'language.english')),
        isSemantics(
          isButton: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(languageOption(_en, 'language.arabic')),
        isSemantics(
          isButton: true,
          isSelected: false,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('completes with the tapped language and closes', (
      tester,
    ) async {
      final results = await _open(tester);

      await tester.tap(languageOption(_en, 'language.arabic'));
      await tester.pumpAndSettle();

      expect(results, [_ar]);
      expect(find.byType(LanguageSheet), findsNothing);
    });

    testWidgets('completes with null when dismissed', (tester) async {
      final results = await _open(tester);

      await tester.tapAt(const Offset(215, 50));
      await tester.pumpAndSettle();

      expect(results, [null]);
      expect(find.byType(LanguageSheet), findsNothing);
    });

    testWidgets('options keep a 44 px tap target', (tester) async {
      await _open(tester);

      for (final key in ['language.english', 'language.arabic']) {
        final target = find.ancestor(
          of: languageOption(_en, key),
          matching: find.byType(InkWell),
        );
        expect(tester.getSize(target).height, greaterThanOrEqualTo(44));
      }
    });
  });
}
