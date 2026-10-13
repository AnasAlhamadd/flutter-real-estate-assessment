import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shell.dart';
import 'package:flutter_real_estate_assessment/core/widget/language_switcher.dart';
import 'package:flutter_real_estate_assessment/core/widget/placeholder_screen.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/pages/auth_screen.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/pages/home_screen.dart';
import 'package:flutter_real_estate_assessment/feature/splash/presentation/pages/splash_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
  /// Default `initialLocation`. Deep links open their own route instead.
  static const String splash = '/splash';

  /// Opened by Splash. UI only: no backend authentication exists yet.
  static const String auth = '/auth';
  static const String home = '/';

  /// Where a successful sign-in will go once real authentication exists.
  /// Nothing navigates here yet, because no sign-in can succeed.
  static const String signedInDestination = home;
  static const String explore = '/explore';
  static const String profile = '/profile';
  static const String propertyDetails = '/property/:id';

  static String propertyDetailsPath(int id) => '/property/$id';

  static GoRouter create({String initialLocation = splash}) => GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (_, _) => const PlaceholderScreen(
      titleKey: AppTextKeys.appTitle,
      messageKey: AppTextKeys.errorsPageNotFound,
    ),
    routes: [
      GoRoute(path: splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: auth, builder: (_, _) => const AuthScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: explore,
                builder: (_, _) =>
                    const PlaceholderScreen(titleKey: AppTextKeys.exploreTitle),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (_, _) => const PlaceholderScreen(
                  titleKey: AppTextKeys.profileTitle,
                  child: LanguageSwitcher(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: propertyDetails,
        builder: (_, _) =>
            const PlaceholderScreen(titleKey: AppTextKeys.detailsTitle),
      ),
    ],
  );
}
