import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

abstract final class AppLocalization {
  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');
  static const List<Locale> supportedLocales = [english, arabic];
  static const String translationsPath = 'assets/translations';

  /// With no saved choice, easy_localization uses the device language when it
  /// is supported and falls back to English (reference Q5).
  static Widget wrap(
    Widget child, {
    AssetLoader assetLoader = const RootBundleAssetLoader(),
    Locale? startLocale,
  }) => EasyLocalization(
    supportedLocales: supportedLocales,
    path: translationsPath,
    fallbackLocale: english,
    startLocale: startLocale,
    useOnlyLangCode: true,
    saveLocale: true,
    assetLoader: assetLoader,
    child: child,
  );
}
