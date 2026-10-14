import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/circle_icon_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _BackButtonStyle { circle, plain, compact }

/// Figma back button: primary-10% circle with an arrow that mirrors in RTL.
class AppBackButton extends StatelessWidget {
  const AppBackButton({this.onPressed, super.key})
    : _style = _BackButtonStyle.circle;

  /// Property Details top bar (`1:4267`): the 28 px arrow without a circle,
  /// centered in an [AppSizes.minTapTarget] square.
  const AppBackButton.plain({this.onPressed, super.key})
    : _style = _BackButtonStyle.plain;

  /// Filter sheet (`1:3973`): a 32 px circle with a 20 px arrow, centered in
  /// an [AppSizes.minTapTarget] square.
  const AppBackButton.compact({this.onPressed, super.key})
    : _style = _BackButtonStyle.compact;

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;
  final _BackButtonStyle _style;

  @override
  Widget build(BuildContext context) {
    final label = MaterialLocalizations.of(context).backButtonTooltip;
    final onTap = onPressed ?? () => Navigator.of(context).maybePop();
    return switch (_style) {
      _BackButtonStyle.circle => CircleIconButton(
        backgroundColor: ColorsApp.primary10,
        semanticLabel: label,
        onPressed: onTap,
        icon: const AppSvgIcon(
          ImagePath.arrowLeft,
          size: AppSizes.iconSize,
          color: ColorsApp.black01,
          matchTextDirection: true,
        ),
      ),
      _BackButtonStyle.plain => _TapTarget(
        label: label,
        onTap: onTap,
        child: const AppSvgIcon(
          ImagePath.arrowLeft,
          size: AppSizes.detailsTopBarIconSize,
          color: ColorsApp.black01,
          matchTextDirection: true,
        ),
      ),
      _BackButtonStyle.compact => _TapTarget(
        label: label,
        onTap: onTap,
        child: Container(
          width: AppSizes.filterBackButtonSize.r,
          height: AppSizes.filterBackButtonSize.r,
          decoration: const BoxDecoration(
            color: ColorsApp.primary10,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const AppSvgIcon(
            ImagePath.arrowLeft,
            size: AppSizes.smallIconSize,
            color: ColorsApp.black01,
            matchTextDirection: true,
          ),
        ),
      ),
    };
  }
}

/// [child] centered in an [AppSizes.minTapTarget] square that reacts to taps.
class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          child: Center(child: child),
        ),
      ),
    );
  }
}
