import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/widget/category_chip.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontally scrolling "All" + API category chips (Figma `1:4478`, Q12).
///
/// A `Row` instead of a `ListView`, so the row height follows the chip text
/// at any text scale.
class HomeCategoryChips extends StatelessWidget {
  const HomeCategoryChips({
    required this.categories,
    required this.selectedSlug,
    required this.onSelected,
    super.key,
  });

  final List<CategoryEntity> categories;

  /// `null` means "All".
  final String? selectedSlug;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(width: AppSizes.chipGap.w);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.screenHorizontalPadding.w,
      ),
      child: Row(
        children: [
          CategoryChip(
            label: context.tr(AppTextKeys.commonAll),
            selected: selectedSlug == null,
            onTap: () => onSelected(null),
          ),
          for (final category in categories) ...[
            gap,
            CategoryChip(
              label: category.name,
              selected: category.slug == selectedSlug,
              onTap: () => onSelected(category.slug),
            ),
          ],
        ],
      ),
    );
  }
}
