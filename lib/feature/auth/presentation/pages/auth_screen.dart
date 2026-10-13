import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/widget/auth_collage.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/widget/auth_intro.dart';
import 'package:flutter_real_estate_assessment/feature/auth/presentation/widget/google_auth_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Auth landing (Figma `1:4499`). UI only: no backend sign-in exists, so the
/// Google button says so instead of navigating, and guests continue to Home.
/// Real sign-in will replace [_showSignInUnavailable] and open
/// [AppRouter.signedInDestination] on success.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void _showSignInUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: CustomText(AppTextKeys.authSignInUnavailable)),
      );
  }

  void _continueAsGuest(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ColorsApp.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                // The panel sits at the bottom and covers the faded end of
                // the collage on short screens; it scrolls only when the
                // panel alone is taller than the screen.
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      PositionedDirectional(
                        top: AppSizes.authCollageTop.h,
                        start: 0,
                        end: 0,
                        child: const Align(
                          alignment: Alignment.topCenter,
                          child: AuthCollage(),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _AuthPanel(
                            onGooglePressed: () =>
                                _showSignInUnavailable(context),
                            onGuestPressed: () => _continueAsGuest(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.onGooglePressed,
    required this.onGuestPressed,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onGuestPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppSizes.authPanelFadeHeight.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ColorsApp.white.withValues(alpha: 0), ColorsApp.white],
              ),
            ),
          ),
        ),
        ColoredBox(
          color: ColorsApp.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.screenHorizontalPadding.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthIntro(),
                SizedBox(height: AppSizes.authTextButtonGap.h),
                GoogleAuthButton(onPressed: onGooglePressed),
                _GuestButton(onPressed: onGuestPressed),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Not in Figma (approved): the only way past Auth until sign-in exists.
class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: ColorsApp.primary,
        minimumSize: const Size.square(AppSizes.minTapTarget),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.screenHorizontalPadding.w,
        ),
      ),
      child: CustomText(
        AppTextKeys.authContinueAsGuest,
        textAlign: TextAlign.center,
        style: AppTextStyles.link,
      ),
    );
  }
}
