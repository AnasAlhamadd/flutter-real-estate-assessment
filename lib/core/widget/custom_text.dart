import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';

/// Shared text widget. Styles come from `AppTextStyles`.
///
/// The default constructor translates a key from `AppTextKeys` with
/// `context.tr`, so it rebuilds when the locale changes, including on
/// kept-alive routes. [CustomText.plain] shows text that must not be
/// translated, such as API data or formatted prices.
///
/// Text scaling always follows the user's accessibility setting.
class CustomText extends StatelessWidget {
  const CustomText(
    String textKey, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textDirection,
    this.semanticsLabel,
    this.upperCase = false,
    super.key,
  }) : _text = textKey,
       _translate = true;

  const CustomText.plain(
    String text, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textDirection,
    this.semanticsLabel,
    this.upperCase = false,
    super.key,
  }) : _text = text,
       _translate = false;

  final String _text;
  final bool _translate;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// Overrides the ambient direction, e.g. to keep Latin-only content LTR
  /// inside the Arabic UI.
  final TextDirection? textDirection;
  final String? semanticsLabel;
  final bool upperCase;

  @override
  Widget build(BuildContext context) {
    final resolved = _translate ? context.tr(_text) : _text;
    return Text(
      upperCase ? resolved.toUpperCase() : resolved,
      style: _styleFor(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
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
