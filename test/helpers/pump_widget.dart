import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/app_theme.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translations.dart';

/// Narrow surface + large text from the testing rules.
const Size narrowSize = Size(320, 640);
const double largeTextScale = 1.3;

/// Pumps a single widget with the app's localization, ScreenUtil and theme,
/// on a surface of [size] logical pixels.
Future<void> pumpLocalizedWidget(
  WidgetTester tester,
  Widget child, {
  Locale locale = AppLocalization.english,
  Size size = AppSizes.designSize,
  double textScale = 1,
  bool settle = true,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  EasyLocalization.logger.enableBuildModes = [];
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  await tester.pumpWidget(
    AppLocalization.wrap(
      _Harness(child: child),
      assetLoader: const FileAssetLoader(),
      startLocale: locale,
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // Translations load asynchronously; endless animations never settle.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

class _Harness extends StatelessWidget {
  const _Harness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppSizes.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        home: Scaffold(body: child),
      ),
    );
  }
}

/// Runs [body] for every locale × {design size at 1.0, narrow at 1.3}.
void testWidgetsInLayouts(
  String description,
  Future<void> Function(
    WidgetTester tester,
    Locale locale,
    Size size,
    double textScale,
  )
  body,
) {
  for (final locale in AppLocalization.supportedLocales) {
    for (final (size, textScale) in [
      (AppSizes.designSize, 1.0),
      (narrowSize, largeTextScale),
    ]) {
      final variant =
          '${locale.languageCode} · ${size.width.toInt()}x${size.height.toInt()} · x$textScale';
      testWidgets('$description ($variant)', (tester) async {
        await body(tester, locale, size, textScale);
      });
    }
  }
}

/// Logical-pixel direction for [locale], used for start/end assertions.
TextDirection directionOf(Locale locale) =>
    locale == AppLocalization.arabic ? TextDirection.rtl : TextDirection.ltr;
