import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Decorative photo collage of the Auth screen (Figma `1:4521`). One static
/// image with the fade baked in, so it isn't mirrored in RTL and is hidden
/// from screen readers.
class AuthCollage extends StatelessWidget {
  const AuthCollage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImagePath.authCollage,
      width: AppSizes.authCollageWidth.r,
      height: AppSizes.authCollageHeight.r,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
