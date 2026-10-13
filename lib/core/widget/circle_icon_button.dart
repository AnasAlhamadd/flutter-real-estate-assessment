import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 44 px circular icon button used in screen headers.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.backgroundColor = ColorsApp.white,
    super.key,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = AppSizes.iconButtonSize.r;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
