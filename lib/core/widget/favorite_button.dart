import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';

/// Heart colors and size per card surface (Figma Iconly Light-Outline Heart).
enum FavoriteButtonVariant {
  /// Featured card: white over the photo gradient.
  onImage(
    iconSize: AppSizes.featuredHeartSize,
    color: ColorsApp.white,
    selectedColor: ColorsApp.white,
  ),

  /// Grid card: Black/03 on white; Primary when selected.
  onSurface(
    iconSize: AppSizes.gridHeartSize,
    color: ColorsApp.black03,
    selectedColor: ColorsApp.primary,
  ),

  /// Property Details top bar (`1:4270`): 28 px, Black/01 over the hero;
  /// Primary when selected, like the grid card.
  detailsTopBar(
    iconSize: AppSizes.detailsTopBarIconSize,
    color: ColorsApp.black01,
    selectedColor: ColorsApp.primary,
  );

  const FavoriteButtonVariant({
    required this.iconSize,
    required this.color,
    required this.selectedColor,
  });

  /// Design pixels, scaled with `.r` by `AppSvgIcon`.
  final double iconSize;
  final Color color;
  final Color selectedColor;
}

/// Favorite toggle: the Figma heart centered in an
/// [AppSizes.minTapTarget] square. Cards place it over their heart slot, so
/// the larger tap area doesn't change the Figma layout.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
    this.variant = FavoriteButtonVariant.onSurface,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final FavoriteButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isFavorite,
      label: context.tr(
        isFavorite ? AppTextKeys.favoritesRemove : AppTextKeys.favoritesAdd,
      ),
      excludeSemantics: true,
      onTap: onPressed,
      child: SizedBox.square(
        dimension: AppSizes.minTapTarget,
        child: InkResponse(
          onTap: onPressed,
          radius: AppSizes.minTapTarget / 2,
          child: Center(
            child: AppSvgIcon(
              isFavorite ? ImagePath.heartBold : ImagePath.heart,
              size: variant.iconSize,
              color: isFavorite ? variant.selectedColor : variant.color,
            ),
          ),
        ),
      ),
    );
  }
}
