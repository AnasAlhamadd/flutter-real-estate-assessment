import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';

/// Translated text for a key from `AppTextKeys`.
///
/// Uses `context.tr`, so it rebuilds when the locale changes, including on
/// kept-alive routes.
class CustomText extends StatelessWidget {
  const CustomText(
    this.textKey, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.upperCase = false,
    super.key,
  });

  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool upperCase;

  @override
  Widget build(BuildContext context) {
    final translated = context.tr(textKey);
    final text = upperCase ? translated.toUpperCase() : translated;
    return Text(
      text,
      style: _styleFor(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Letter spacing pulls joined Arabic letters apart, so the Arabic locale
  /// drops it for every text, Latin included.
  TextStyle? _styleFor(BuildContext context) {
    final spacing = style?.letterSpacing;
    if (spacing == null ||
        spacing == 0 ||
        context.locale != AppLocalization.arabic) {
      return style;
    }
    return style!.copyWith(letterSpacing: 0);
  }
}
