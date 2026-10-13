import 'package:flutter_real_estate_assessment/core/widget/app_shell.dart';
import 'package:flutter_real_estate_assessment/core/widget/language_switcher.dart';
import 'package:flutter_real_estate_assessment/core/widget/placeholder_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
  static const String home = '/';
  static const String explore = '/explore';
  static const String profile = '/profile';
  static const String propertyDetails = '/property/:id';

  static String propertyDetailsPath(int id) => '/property/$id';

  static GoRouter create({String initialLocation = home}) => GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (_, _) => const PlaceholderScreen(
      titleKey: 'app.title',
      messageKey: 'errors.page_not_found',
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (_, _) =>
                    const PlaceholderScreen(titleKey: 'home.title'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: explore,
                builder: (_, _) =>
                    const PlaceholderScreen(titleKey: 'explore.title'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (_, _) => const PlaceholderScreen(
                  titleKey: 'profile.title',
                  child: LanguageSwitcher(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: propertyDetails,
        builder: (_, _) => const PlaceholderScreen(titleKey: 'details.title'),
      ),
    ],
  );
}
