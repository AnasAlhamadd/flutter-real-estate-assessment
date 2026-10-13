import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sticky price bar (Figma `1:4420`). "Booking Now" is hidden: there is no
/// booking endpoint (Q9). The Figma bottom padding (36) already covers the
/// home indicator, so the safe-area inset only counts when it's larger.
class DetailsPriceBar extends StatelessWidget {
  const DetailsPriceBar({required this.price, super.key});

  final double price;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(AppSizes.radiusPriceBar.r);
    final bottom = math.max(
      AppSizes.detailsPriceBarBottom.h,
      MediaQuery.viewPaddingOf(context).bottom,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsApp.white,
        border: Border.all(color: ColorsApp.primary10),
        borderRadius: BorderRadius.vertical(top: radius),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSizes.detailsPriceBarSide.w,
            AppSizes.detailsPriceBarTop.h,
            AppSizes.detailsPriceBarSide.w,
            bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(
                AppTextKeys.detailsPrice,
                upperCase: true,
                style: AppTextStyles.detailsPriceLabel,
              ),
              SizedBox(height: AppSizes.detailsPriceLabelGap.h),
              CustomText.plain(
                Formatters.price(price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.detailsPrice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
