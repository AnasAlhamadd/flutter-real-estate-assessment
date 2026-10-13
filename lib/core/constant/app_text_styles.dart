import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Rubik text styles from Figma (reference §5.3), scaled with ScreenUtil.
///
/// `fontWeight` alone drives the `wght` axis of the bundled variable font
/// (covered by `test/core/theme/rubik_font_test.dart`).
abstract final class AppTextStyles {
  static const String fontFamily = 'Rubik';

  static TextStyle get detailsTitle => _rubik(24, FontWeight.w700, 1.2);
  static TextStyle get sectionTitle => _rubik(20, FontWeight.w600, 1.2);

  static TextStyle get featuredTitle =>
      _rubik(20, FontWeight.w700, 1.1, color: ColorsApp.white);
  static TextStyle get featuredPrice =>
      _rubik(20, FontWeight.w700, 1.2, color: ColorsApp.white);
  static TextStyle get featuredLocation => _rubik(
    16,
    FontWeight.w400,
    1.4,
    color: ColorsApp.white,
    letterSpacing: 0.2,
  );

  static TextStyle get listTitle => _rubik(18, FontWeight.w600, 1.4);
  static TextStyle get listPrice =>
      _rubik(18, FontWeight.w600, 1.2, color: ColorsApp.primary);
  static TextStyle get listLocation =>
      _rubik(14, FontWeight.w400, 1.4, color: ColorsApp.black02);

  static TextStyle get gridTitle => _rubik(16, FontWeight.w600, 1.2);
  static TextStyle get gridPrice =>
      _rubik(16, FontWeight.w600, 1.2, color: ColorsApp.primary);
  static TextStyle get gridLocation =>
      _rubik(12, FontWeight.w400, null, color: ColorsApp.black03);

  static TextStyle get link =>
      _rubik(16, FontWeight.w600, 1.4, color: ColorsApp.primary);
  static TextStyle get button =>
      _rubik(16, FontWeight.w600, 1.4, color: ColorsApp.white);

  static TextStyle get chipActive =>
      _rubik(14, FontWeight.w600, 1.8, color: ColorsApp.white);
  static TextStyle get chipInactive => _rubik(14, FontWeight.w400, 1.8);

  static TextStyle get searchHint =>
      _rubik(14, FontWeight.w400, 1.3, color: ColorsApp.black03);
  static TextStyle get searchInput => _rubik(14, FontWeight.w600, 1.3);

  static TextStyle get badgeLarge =>
      _rubik(12, FontWeight.w600, 1.4, color: ColorsApp.rating);
  static TextStyle get badgeMedium =>
      _rubik(10, FontWeight.w600, 1.4, color: ColorsApp.rating);
  static TextStyle get badgeSmall =>
      _rubik(8, FontWeight.w600, 1.4, color: ColorsApp.rating);

  /// Splash title and tagline (Figma `1:4561`, `1:4562`). Figma uses Outfit
  /// Black / Medium, which has no Arabic glyphs, so Rubik keeps the same
  /// weights, size and tracking (Q6). Both are shown uppercase.
  static TextStyle get splashTitle => _rubik(
    20,
    FontWeight.w900,
    null,
    color: ColorsApp.primary,
    letterSpacing: 2,
  );
  static TextStyle get splashTagline => _rubik(
    12,
    FontWeight.w500,
    null,
    color: ColorsApp.black02,
    letterSpacing: 1.2,
  );

  /// `Paragraph/Medium/P12 - LH 130%`.
  static TextStyle get navLabel => _rubik(12, FontWeight.w500, 1.3);

  /// `Paragraph/Regular/P14 - LH 180%`.
  static TextStyle get bodyRegular14 =>
      _rubik(14, FontWeight.w400, 1.8, color: ColorsApp.black02);

  /// `Paragraph/Medium/P16 - LH 130%`.
  static TextStyle get bodyMedium16 => _rubik(16, FontWeight.w500, 1.3);

  static TextStyle _rubik(
    double size,
    FontWeight weight,
    double? height, {
    Color color = ColorsApp.black01,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size.sp,
    fontWeight: weight,
    height: height,
    color: color,
    letterSpacing: letterSpacing,
  );
}
