import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/language_sheet.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/profile_menu_row.dart';
import 'package:flutter_test/flutter_test.dart';

import 'translations.dart';

/// The option named [option] (a `language.*` key) inside the open sheet.
Finder languageOption(Locale displayLocale, String option) => find.descendant(
  of: find.byType(LanguageSheet),
  matching: find.text(translate(displayLocale, option)),
);

/// From the Profile tab shown in [from]: opens the Language sheet and picks
/// the language named by [optionKey].
Future<void> pickLanguageOnProfile(
  WidgetTester tester, {
  required Locale from,
  required String optionKey,
}) async {
  await tester.tap(find.byType(ProfileMenuRow));
  await tester.pumpAndSettle();
  await tester.tap(languageOption(from, optionKey));
  await tester.pumpAndSettle();
}
