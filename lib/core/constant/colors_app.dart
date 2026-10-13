import 'package:flutter/widgets.dart';

/// Figma colors of the approved blue set (reference §5.3, Q10).
abstract final class ColorsApp {
  // Named Figma variables.
  static const Color black01 = Color(0xFF191D31);
  static const Color black02 = Color(0xFF666876);
  static const Color black03 = Color(0xFF8C8E98);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyscale400 = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFF75555);

  // Raw values used directly in the design.
  static const Color primary = Color(0xFF0061FF);
  static const Color rating = Color(0xFF246BFD);
  static const Color searchBackground = Color(0xFFFBFBFD);

  /// Inactive chip fill, icon-circle fill, search border, tag fill.
  static const Color primary4 = Color(0x0A0061FF);

  /// Chip border, nav top border, back-button fill.
  static const Color primary10 = Color(0x1A0061FF);

  static const Color overlay = Color(0x4D000000);
  static const Color badgeBackground = Color(0xE6FFFFFF);

  /// Featured-card gradient: transparent → `rgba(32,32,32,0.70)`.
  static const Color featuredGradientStart = Color(0x00202020);
  static const Color featuredGradientEnd = Color(0xB3202020);

  static const Color cardShadow = Color(0x0D04060F);
  static const Color badgeShadow = Color(0x1F04060F);
  static const Color buttonShadow = Color(0x40246BFD);

  /// Auth Google button shadow: `rgba(0,0,0,0.2)`.
  static const Color authButtonShadow = Color(0x33000000);
}
