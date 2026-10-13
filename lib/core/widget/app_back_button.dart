import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/circle_icon_button.dart';

/// Figma back button: primary-10% circle with an arrow that mirrors in RTL.
class AppBackButton extends StatelessWidget {
  const AppBackButton({this.onPressed, super.key});

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      backgroundColor: ColorsApp.primary10,
      semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: const AppSvgIcon(
        ImagePath.arrowLeft,
        size: AppSizes.iconSize,
        color: ColorsApp.black01,
        matchTextDirection: true,
      ),
    );
  }
}
