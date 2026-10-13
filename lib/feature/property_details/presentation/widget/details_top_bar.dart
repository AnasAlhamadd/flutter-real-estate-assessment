import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_back_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/property_favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Details top bar (Figma `1:4266`) over the hero: back at the start, heart
/// at the end. Share (`1:4271`) is hidden: it needs a package outside the
/// approved stack (Q8). Includes the status-bar inset.
class DetailsTopBar extends StatelessWidget {
  const DetailsTopBar({this.property, super.key});

  /// The heart needs the property for its saved snapshot; hidden when `null`.
  final PropertyEntity? property;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final tapInset =
        (AppSizes.minTapTarget - AppSizes.detailsTopBarIconSize.r) / 2;
    final horizontal = math.max(
      0.0,
      AppSizes.detailsTopBarPadding.w - tapInset,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        insets.left + horizontal,
        insets.top + AppSizes.detailsTopBarTop.h,
        insets.right + horizontal,
        0,
      ),
      child: SizedBox(
        height: math.max(AppSizes.detailsTopBarHeight.h, AppSizes.minTapTarget),
        child: Row(
          children: [
            const AppBackButton.plain(),
            const Spacer(),
            if (property case final property?)
              PropertyFavoriteButton(
                property: property,
                variant: FavoriteButtonVariant.detailsTopBar,
              ),
          ],
        ),
      ),
    );
  }
}
