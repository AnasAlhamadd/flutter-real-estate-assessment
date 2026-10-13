import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: ColorsApp.white,
    colorScheme: const ColorScheme.light(
      primary: ColorsApp.primary,
      onPrimary: ColorsApp.white,
      surface: ColorsApp.white,
      onSurface: ColorsApp.black01,
      error: ColorsApp.error,
      onError: ColorsApp.white,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ColorsApp.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorsApp.white,
      foregroundColor: ColorsApp.black01,
      surfaceTintColor: ColorsApp.white,
      elevation: 0,
    ),
  );
}
