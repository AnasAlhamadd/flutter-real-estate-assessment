import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "search-bar": search icon, text input and a filter button.
///
/// Set [readOnly] with [onTap] for the Home bar that only opens Explore.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onFilterTap,
    this.readOnly = false,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  /// Hides the filter button when `null`.
  final VoidCallback? onFilterTap;
  final bool readOnly;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: AppSizes.searchFieldHeight.h),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.searchFieldInset.w,
      ),
      decoration: BoxDecoration(
        color: ColorsApp.searchBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSearchField.r),
        border: Border.all(color: ColorsApp.primary4),
      ),
      child: Row(
        children: [
          const AppSvgIcon(
            ImagePath.search,
            size: AppSizes.smallIconSize,
            color: ColorsApp.black03,
          ),
          SizedBox(width: AppSizes.searchFieldIconGap.w),
          Expanded(child: _buildInput(context)),
          if (onFilterTap != null) _FilterButton(onTap: onFilterTap!),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: 1,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.searchInput,
      cursorColor: ColorsApp.primary,
      decoration: InputDecoration(
        hintText: context.tr(AppTextKeys.commonSearchHint),
        hintStyle: AppTextStyles.searchHint,
        hintMaxLines: 1,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.tr(AppTextKeys.commonFilter),
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: AppSizes.smallIconSize.r,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppSizes.searchFieldIconGap.w,
          ),
          child: const AppSvgIcon(
            ImagePath.filter,
            size: AppSizes.smallIconSize,
            color: ColorsApp.black03,
          ),
        ),
      ),
    );
  }
}
