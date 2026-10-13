import 'package:flutter/services.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/pages/auth_screen.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/pages/property_details_screen.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/pages/search_screen.dart';
import 'package:flutter_real_estate_assessment/feature/splash/presentation/pages/splash_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/layout_expectations.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_viewports.dart';
import '../../../../helpers/translations.dart';

final List<TestViewport> _viewports = testViewports
    .where((viewport) => const [320.0, 430.0].contains(viewport.size.width))
    .toList();

/// Lets the splash timer fire and the Auth route settle.
Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(SplashScreen.displayDuration);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in AppLocalization.supportedLocales) {
    for (final viewport in _viewports) {
      for (final textScale in const [1.0, 1.3]) {
        testWidgets('shows the logo, title and tagline on $viewport · '
            '${locale.languageCode} · x$textScale', (tester) async {
          await pumpApp(
            tester,
            locale: locale,
            viewport: viewport,
            textScale: textScale,
            initialLocation: AppRouter.splash,
          );

          expectNoLayoutErrors(tester);
          expectDirectionFor(tester, locale);
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is SvgPicture &&
                  (widget.bytesLoader as SvgAssetLoader).assetName ==
                      ImagePath.splashLogo,
            ),
            findsOneWidget,
          );
          expect(
            find.text(translate(locale, 'app.title').toUpperCase()),
            findsOneWidget,
          );
          expect(
            find.text(translate(locale, 'splash.tagline').toUpperCase()),
            findsOneWidget,
          );

          await _finishSplash(tester);
        });
      }
    }
  }

  testWidgets('opens Auth after the display duration, not before', (
    tester,
  ) async {
    final start = tester.binding.clock.now();
    await pumpApp(tester, initialLocation: AppRouter.splash);
    final elapsed = tester.binding.clock.now().difference(start);

    await tester.pump(
      SplashScreen.displayDuration - elapsed - const Duration(milliseconds: 50),
    );
    expect(find.byType(SplashScreen), findsOneWidget);

    await _finishSplash(tester);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('replaces itself so Back cannot return to it', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.splash);
    await _finishSplash(tester);

    final router = GoRouter.of(tester.element(find.byType(AuthScreen)));
    expect(router.canPop(), isFalse);
  });

  testWidgets('does not navigate after it is disposed early', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.splash);

    GoRouter.of(
      tester.element(find.byType(SplashScreen)),
    ).go(AppRouter.explore);
    await tester.pumpAndSettle();
    await tester.pump(SplashScreen.displayDuration * 2);
    await tester.pumpAndSettle();

    expectNoLayoutErrors(tester);
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.byType(AuthScreen), findsNothing);
  });

  test('precacheLogo fills the SVG cache before runApp', () async {
    svg.cache.clear();
    addTearDown(svg.cache.clear);

    await SplashScreen.precacheLogo();

    var parsedAgain = false;
    await svg.cache.putIfAbsent(
      const SvgAssetLoader(ImagePath.splashLogo).cacheKey(null),
      () async {
        parsedAgain = true;
        return ByteData(0);
      },
    );
    expect(parsedAgain, isFalse);
  });

  testWidgets('the logo reads the entry that precacheLogo fills', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: AppRouter.splash);

    final logo = find.byWidgetPredicate(
      (widget) =>
          widget is SvgPicture &&
          (widget.bytesLoader as SvgAssetLoader).assetName ==
              ImagePath.splashLogo,
    );
    final loader = tester.widget<SvgPicture>(logo).bytesLoader;
    expect(
      (loader as SvgAssetLoader).cacheKey(tester.element(logo)),
      const SvgAssetLoader(ImagePath.splashLogo).cacheKey(null),
    );

    await _finishSplash(tester);
  });

  testWidgets('deep links open their route without the splash or Auth', (
    tester,
  ) async {
    tester.platformDispatcher.defaultRouteNameTestValue =
        AppRouter.propertyDetailsPath(1);
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

    await pumpApp(tester, initialLocation: AppRouter.splash);
    await tester.pump(SplashScreen.displayDuration * 2);
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(AuthScreen), findsNothing);
    expect(find.byType(PropertyDetailsScreen), findsOneWidget);
  });
}
