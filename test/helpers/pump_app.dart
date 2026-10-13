import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_real_estate_assessment/app.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/services/phone_dialer.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/repositories/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_home_repository.dart';
import 'test_viewports.dart';
import 'translations.dart';

const TestViewport defaultViewport = TestViewport(
  'large phone',
  Size(430, 932),
  FakeViewPadding(top: 47, bottom: 34),
);

/// Pumps the real app (EasyLocalization + ScreenUtil + router) on a simulated
/// device. `preferences` seeds SharedPreferences, e.g. `{'locale': 'ar'}`.
/// Screens get their data from [repository] (sample data by default) and
/// [favorites] (empty by default); [phoneDialer] defaults to a recording
/// fake. Pass `settle: false` while a skeleton is visible, because its
/// shimmer never settles.
Future<void> pumpApp(
  WidgetTester tester, {
  Locale locale = AppLocalization.english,
  TestViewport viewport = defaultViewport,
  double textScale = 1,
  String initialLocation = AppRouter.home,
  Map<String, Object> preferences = const {},
  HomeRepository? repository,
  FavoritesRepository? favorites,
  PropertiesRepository? properties,
  SearchRepository? search,
  PhoneDialer? phoneDialer,
  bool settle = true,
}) async {
  registerScreenDependencies(
    repository ?? FakeHomeRepository(),
    favorites: favorites,
    properties: properties,
    search: search,
    phoneDialer: phoneDialer,
  );
  tester.view
    ..physicalSize = viewport.size
    ..devicePixelRatio = 1
    ..padding = viewport.padding
    ..viewPadding = viewport.padding;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  EasyLocalization.logger.enableBuildModes = [];
  SharedPreferences.setMockInitialValues(preferences);
  await EasyLocalization.ensureInitialized();

  await tester.pumpWidget(
    AppLocalization.wrap(
      App(initialLocation: initialLocation),
      assetLoader: const FileAssetLoader(),
      startLocale: locale,
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}
