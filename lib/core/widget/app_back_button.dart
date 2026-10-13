import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/circle_icon_button.dart';

/// Figma back button: primary-10% circle with an arrow that mirrors in RTL.
class AppBackButton extends StatelessWidget {
  const AppBackButton({this.onPressed, super.key}) : _plain = false;

  /// Property Details top bar (`1:4267`): the 28 px arrow without a circle,
  /// centered in an [AppSizes.minTapTarget] square.
  const AppBackButton.plain({this.onPressed, super.key}) : _plain = true;

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;
  final bool _plain;

  @override
  Widget build(BuildContext context) {
    final label = MaterialLocalizations.of(context).backButtonTooltip;
    final onTap = onPressed ?? () => Navigator.of(context).maybePop();
    if (_plain) {
      return Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: SizedBox.square(
          dimension: AppSizes.minTapTarget,
          child: InkResponse(
            onTap: onTap,
            radius: AppSizes.minTapTarget / 2,
            child: const Center(
              child: AppSvgIcon(
                ImagePath.arrowLeft,
                size: AppSizes.detailsTopBarIconSize,
                color: ColorsApp.black01,
                matchTextDirection: true,
              ),
            ),
          ),
        ),
      );
    }
    return CircleIconButton(
      backgroundColor: ColorsApp.primary10,
      semanticLabel: label,
      onPressed: onTap,
      icon: const AppSvgIcon(
        ImagePath.arrowLeft,
        size: AppSizes.iconSize,
        color: ColorsApp.black01,
        matchTextDirection: true,
      ),
    );
  }
}
