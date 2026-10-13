import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sticky price bar (Figma `1:4420`): price and "Booking Now". The Figma
/// bottom padding (36) already covers the home indicator, so the safe-area
/// inset only counts when it's larger.
class DetailsPriceBar extends StatelessWidget {
  const DetailsPriceBar({
    required this.price,
    required this.onBooking,
    super.key,
  });

  final double price;

  /// There is no booking endpoint (Q9), so the screen shows a message.
  final VoidCallback onBooking;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gap = AppSizes.detailsPriceButtonGap.w;
              return Row(
                children: [
                  // The price keeps its own width so the button fills the
                  // rest up to the end; capped at half so a long price
                  // ellipsizes instead of squeezing the button.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: (constraints.maxWidth - gap) / 2,
                    ),
                    child: _Price(price: price),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: AppButton(
                      label: context.tr(AppTextKeys.detailsBookingNow),
                      onPressed: onBooking,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          AppTextKeys.detailsPrice,
          upperCase: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    );
  }
}
