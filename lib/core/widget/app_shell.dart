import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

/// Tab shell with the Figma bottom navigation (Home, Explore, Profile).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          AppBottomNavItem(
            label: context.tr(AppTextKeys.navHome),
            activeIcon: ImagePath.homeBold,
            inactiveIcon: ImagePath.homeLight,
          ),
          AppBottomNavItem(
            label: context.tr(AppTextKeys.navExplore),
            activeIcon: ImagePath.searchBold,
            inactiveIcon: ImagePath.search,
          ),
          AppBottomNavItem(
            label: context.tr(AppTextKeys.navProfile),
            activeIcon: ImagePath.profileBold,
            inactiveIcon: ImagePath.profileLight,
          ),
        ],
      ),
    );
  }
}
