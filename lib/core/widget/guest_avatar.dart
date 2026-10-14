import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Stand-in for the user photo while there is no signed-in user (Q11): the
/// Profile icon on Greyscale/400. Decorative, so hidden from screen readers.
class GuestAvatar extends StatelessWidget {
  const GuestAvatar({required this.size, super.key});

  /// Diameter in design pixels; scaled with `.r`.
  final double size;

  /// Home draws a 24 px icon in its 44 px avatar; other sizes keep the ratio.
  static const double iconRatio = AppSizes.iconSize / AppSizes.homeAvatarSize;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size.r,
        height: size.r,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: ColorsApp.greyscale400,
          shape: BoxShape.circle,
        ),
        child: AppSvgIcon(
          ImagePath.profileLight,
          size: size * iconRatio,
          color: ColorsApp.white,
        ),
      ),
    );
  }
}
