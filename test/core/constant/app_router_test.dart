import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/app.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/pages/auth_screen.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/splash/presentation/pages/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/layout_expectations.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/translations.dart';

const Locale _en = AppLocalization.english;

void main() {
  test('the app starts on Splash', () {
    expect(const App().initialLocation, AppRouter.splash);
  });

  test('a successful sign-in will open Home', () {
    expect(AppRouter.signedInDestination, AppRouter.home);
  });

  testWidgets('launch goes Splash → Auth, and the guest action → Home', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: AppRouter.splash);
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(SplashScreen.displayDuration);
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);

    await tester.tap(find.text(translate(_en, 'auth.continue_as_guest')));
    await tester.pumpAndSettle();

    final home = find.byType(HomeScreen);
    expect(home, findsOneWidget);
    expect(GoRouter.of(tester.element(home)).canPop(), isFalse);
  });

  testWidgets('/auth opens Auth directly', (tester) async {
    await pumpApp(tester, initialLocation: AppRouter.auth);

    expectNoLayoutErrors(tester);
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
