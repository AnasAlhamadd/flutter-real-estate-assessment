import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  final String label;

  /// Iconly Bold variant.
  final String activeIcon;

  /// Iconly Light variant.
  final String inactiveIcon;
}

/// Figma "Navbar": 86 px tall with a primary-10% top border. The active tab
/// uses the bold icon in primary, the others the light icon in Black/02.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ColorsApp.white,
        border: Border(top: BorderSide(color: ColorsApp.primary10)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: AppSizes.navBarHeight.h),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.navBarSidePadding.w,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavTab(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ColorsApp.primary : ColorsApp.black02;
    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.navBarIconTop.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                selected ? item.activeIcon : item.inactiveIcon,
                size: AppSizes.iconSize,
                color: color,
              ),
              SizedBox(height: AppSizes.navBarIconLabelGap.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.navLabel.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
