import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_search_field.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_widget.dart';
import '../../helpers/translations.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Finder clearButton(Locale locale) =>
      find.bySemanticsLabel(translate(locale, AppTextKeys.commonClearSearch));

  testWidgets('hides the clear button while the field is empty', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      AppSearchField(controller: controller),
    );

    expect(clearButton(AppLocalization.english), findsNothing);
  });

  testWidgets('hides the clear button on the read-only Home bar', (
    tester,
  ) async {
    controller.text = 'villa';
    await pumpLocalizedWidget(
      tester,
      AppSearchField(controller: controller, readOnly: true, onTap: () {}),
    );

    expect(clearButton(AppLocalization.english), findsNothing);
  });

  for (final locale in AppLocalization.supportedLocales) {
    testWidgets('clears the text and reports an empty query '
        '(${locale.languageCode})', (tester) async {
      final changes = <String>[];
      await pumpLocalizedWidget(
        tester,
        AppSearchField(controller: controller, onChanged: changes.add),
        locale: locale,
      );

      expect(
        Directionality.of(tester.element(find.byType(TextField))),
        directionOf(locale),
      );

      await tester.enterText(find.byType(TextField), 'villa');
      await tester.pump();
      expect(clearButton(locale), findsOneWidget);

      await tester.tap(clearButton(locale));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(changes, ['villa', '']);
      expect(clearButton(locale), findsNothing);
    });
  }
}
