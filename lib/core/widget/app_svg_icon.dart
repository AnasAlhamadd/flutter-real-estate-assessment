import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Square SVG icon from `ImagePath`.
///
/// [color] tints the whole shape; leave it `null` for multicolor icons such as
/// the star. Set [matchTextDirection] for arrows so they mirror in RTL.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.assetPath, {
    required this.size,
    this.color,
    this.matchTextDirection = false,
    super.key,
  });

  final String assetPath;

  /// Size in design pixels; scaled with `.r`.
  final double size;
  final Color? color;
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size.r,
      height: size.r,
      matchTextDirection: matchTextDirection,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
