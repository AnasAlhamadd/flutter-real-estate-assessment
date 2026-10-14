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
    this.filterActive = false,
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

  /// Not in Figma: tints the filter icon primary while filters are applied,
  /// so filtered results are never mistaken for the full list.
  final bool filterActive;
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
          if (controller != null && !readOnly)
            _ClearButton(controller: controller!, onCleared: onChanged),
          if (onFilterTap != null)
            _FilterButton(onTap: onFilterTap!, active: filterActive),
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

/// Not in Figma: clears the typed query. Shown only while there is text, and
/// reports the empty text through [onCleared] like a normal edit.
class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller, this.onCleared});

  final TextEditingController controller;
  final ValueChanged<String>? onCleared;

  void _clear() {
    controller.clear();
    onCleared?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return Semantics(
          button: true,
          label: context.tr(AppTextKeys.commonClearSearch),
          excludeSemantics: true,
          onTap: _clear,
          child: InkResponse(
            onTap: _clear,
            radius: AppSizes.minTapTarget / 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.minTapTarget,
              ),
              child: Center(
                widthFactor: 1,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: AppSizes.searchFieldIconGap.w,
                  ),
                  child: const AppSvgIcon(
                    ImagePath.close,
                    size: AppSizes.smallIconSize,
                    color: ColorsApp.black03,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Filter icon at the field's end (Search-v1 `1:4146`). The tap area spans
/// the field's height and the icon gap, so it stays [AppSizes.minTapTarget]
/// tall without moving the Figma icon.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap, required this.active});

  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.tr(AppTextKeys.commonFilter),
      value: active ? context.tr(AppTextKeys.filterActive) : null,
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: AppSizes.minTapTarget / 2,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          child: Center(
            widthFactor: 1,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSizes.searchFieldIconGap.w,
              ),
              child: AppSvgIcon(
                ImagePath.filter,
                size: AppSizes.smallIconSize,
                color: active ? ColorsApp.primary : ColorsApp.black03,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
