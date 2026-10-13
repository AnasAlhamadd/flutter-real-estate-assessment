import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Launch screen (Figma `1:4551`). Shows the logo briefly, then replaces
/// itself with Auth so Back never returns here.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration displayDuration = Duration(milliseconds: 1500);

  static const SvgAssetLoader _logoLoader = SvgAssetLoader(
    ImagePath.splashLogo,
  );

  /// Parses the logo into `svg.cache` before `runApp`. Otherwise the parse
  /// runs in an isolate after the splash mounts and uses up most of
  /// [displayDuration] (about 1 s in debug builds) before the logo appears.
  static Future<void> precacheLogo() async {
    try {
      await _logoLoader.loadBytes(null);
    } on Object {
      // Only the head start is lost; SvgPicture loads the asset again.
    }
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.displayDuration, _openAuth);
  }

  void _openAuth() {
    if (mounted) context.go(AppRouter.auth);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ColorsApp.white,
        body: SafeArea(child: Center(child: _SplashLogo())),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.screenHorizontalPadding.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture(
            SplashScreen._logoLoader,
            width: AppSizes.splashLogoWidth.r,
            height: AppSizes.splashLogoHeight.r,
            excludeFromSemantics: true,
          ),
          SizedBox(height: AppSizes.splashLogoTextGap.h),
          CustomText(
            AppTextKeys.appTitle,
            upperCase: true,
            textAlign: TextAlign.center,
            style: AppTextStyles.splashTitle,
          ),
          SizedBox(height: AppSizes.splashTitleTaglineGap.h),
          CustomText(
            AppTextKeys.splashTagline,
            upperCase: true,
            textAlign: TextAlign.center,
            style: AppTextStyles.splashTagline,
          ),
        ],
      ),
    );
  }
}
