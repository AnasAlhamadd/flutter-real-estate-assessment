import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/widget/category_chip.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_state.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/filter_section.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Property Type" (Figma `1:4012`): multi-select chips of the API
/// categories (Q12). None selected means every category. Hidden while the
/// categories are unavailable.
class FilterCategorySection extends StatelessWidget {
  const FilterCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedCategories != current.selectedCategories,
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();
        final cubit = context.read<FilterCubit>();
        final gap = AppSizes.filterChipGap.r;
        return Padding(
          padding: EdgeInsets.only(top: AppSizes.filterSectionGap.h),
          child: FilterSection(
            titleKey: AppTextKeys.filterPropertyType,
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final category in state.categories)
                  CategoryChip(
                    label: category.name,
                    selected: state.selectedCategories.contains(category.slug),
                    verticalPadding: AppSizes.filterChipVerticalPadding,
                    onTap: () => cubit.toggleCategory(category.slug),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
