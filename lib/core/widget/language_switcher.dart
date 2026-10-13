import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';

/// Temporary switcher until the Figma Profile "Language" row (Phase 5).
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Locale>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: AppLocalization.english,
          label: CustomText(AppTextKeys.languageEnglish),
        ),
        ButtonSegment(
          value: AppLocalization.arabic,
          label: CustomText(AppTextKeys.languageArabic),
        ),
      ],
      selected: {context.locale},
      onSelectionChanged: (selection) => context.setLocale(selection.first),
    );
  }
}
