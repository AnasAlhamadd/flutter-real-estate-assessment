import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_divider.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/language_sheet.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/profile_menu_row.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/profile_user_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Profile tab (Figma `1:3786`), reduced to the in-app language switch (Q17).
///
/// Hidden: the bell (Q13), the avatar edit badge, and every menu row without
/// a feature (My Booking … Logout).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontal = AppSizes.screenHorizontalPadding.w;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontal,
                AppSizes.profileHeaderTop.h,
                horizontal,
                AppSizes.sectionGap.h,
              ),
              sliver: SliverList.list(
                children: [
                  const _ProfileHeader(),
                  SizedBox(height: AppSizes.profileHeaderContentGap.h),
                  const ProfileUserInfo(),
                  SizedBox(height: AppSizes.profileDividerGap.h),
                  const AppDivider(),
                  SizedBox(
                    height: math.max(
                      0,
                      AppSizes.profileDividerGap.h - ProfileMenuRow.overhang,
                    ),
                  ),
                  ProfileMenuRow(
                    icon: ImagePath.language,
                    labelKey: AppTextKeys.languageTitle,
                    value: context.tr(LanguageSheet.nameKeyFor(context.locale)),
                    onTap: () => _changeLanguage(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Applies the picked language at once; easy_localization persists it.
  static Future<void> _changeLanguage(BuildContext context) async {
    final locale = await showLanguageSheet(context);
    if (locale == null || !context.mounted || locale == context.locale) return;
    await context.setLocale(locale);
  }
}

/// Figma head `1:3808`: the title in a 44 px row. The bell is hidden (Q13).
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: AppSizes.profileHeaderHeight.h),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          header: true,
          child: CustomText(
            AppTextKeys.profileTitle,
            style: AppTextStyles.profileTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
