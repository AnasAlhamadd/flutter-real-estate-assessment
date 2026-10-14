import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/profile/presentation/widget/profile_menu_row.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Opens the language picker of the Profile "Language" row. Completes with
/// the chosen locale, or `null` when the sheet is dismissed.
///
/// Figma has no picker, so the sheet follows the Filter sheet (white, 24 px
/// top corners, dim overlay, root navigator so it covers the nav bar).
Future<Locale?> showLanguageSheet(BuildContext context) {
  final radius = Radius.circular(AppSizes.radiusFilterSheet.r);
  return showModalBottomSheet<Locale>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: ColorsApp.white,
    barrierColor: ColorsApp.overlay,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: radius),
    ),
    builder: (_) => const LanguageSheet(),
  );
}

/// Title and one option per supported language, each in its own language,
/// with a check on the current one.
class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  static String nameKeyFor(Locale locale) => locale == AppLocalization.arabic
      ? AppTextKeys.languageArabic
      : AppTextKeys.languageEnglish;

  @override
  Widget build(BuildContext context) {
    final current = context.locale;
    final horizontal = AppSizes.screenHorizontalPadding.w;
    final overhang = ProfileMenuRow.overhang;
    final bottom = math.max(
      MediaQuery.viewPaddingOf(context).bottom,
      AppSizes.sectionGap.h,
    );
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        horizontal,
        AppSizes.filterSheetTop.h,
        horizontal,
        math.max(0, bottom - overhang),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: CustomText(
              AppTextKeys.languageTitle,
              style: AppTextStyles.bodyMedium16,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: math.max(0, AppSizes.sectionGap.h - overhang)),
          for (final (index, locale)
              in AppLocalization.supportedLocales.indexed) ...[
            if (index > 0)
              SizedBox(
                height: math.max(
                  0,
                  AppSizes.profileMenuRowGap.h - 2 * overhang,
                ),
              ),
            _LanguageOption(
              locale: locale,
              selected: locale == current,
              onTap: () => Navigator.of(context).pop(locale),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ColorsApp.primary : ColorsApp.black01;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: ProfileMenuRow.overhang),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: AppSizes.profileMenuRowHeight.r,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      LanguageSheet.nameKeyFor(locale),
                      style: AppTextStyles.profileMenuLabel.copyWith(
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSizes.inlineTextGap.w),
                  if (selected)
                    const AppSvgIcon(
                      ImagePath.check,
                      size: AppSizes.iconSize,
                      color: ColorsApp.primary,
                    )
                  else
                    SizedBox.square(dimension: AppSizes.iconSize.r),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
