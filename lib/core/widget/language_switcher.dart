import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';

/// Temporary switcher until the Figma Profile "Language" row (Phase 5).
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Locale>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: AppLocalization.english,
          label: Text(context.tr('language.english')),
        ),
        ButtonSegment(
          value: AppLocalization.arabic,
          label: Text(context.tr('language.arabic')),
        ),
      ],
      selected: {context.locale},
      onSelectionChanged: (selection) => context.setLocale(selection.first),
    );
  }
}
