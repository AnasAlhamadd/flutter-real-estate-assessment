import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/filter_category_section.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/filter_price_section.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/filter_sheet_header.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Opens the Filter sheet (Figma `1:3867`) for the Explore [query]
/// (normalized; empty for the whole catalog), starting from [applied].
/// Completes with the chosen filter on "Set Filter", or `null` when the sheet
/// is closed without applying.
Future<PropertyFilter?> showFilterSheet(
  BuildContext context, {
  required String query,
  required PropertyFilter applied,
}) {
  final radius = Radius.circular(AppSizes.radiusFilterSheet.r);
  return showModalBottomSheet<PropertyFilter>(
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
    constraints: BoxConstraints(
      maxHeight:
          MediaQuery.sizeOf(context).height *
          AppSizes.filterSheetMaxHeightFactor,
    ),
    builder: (_) => BlocProvider(
      create: (_) => sl<FilterCubit>()..load(query: query, applied: applied),
      child: const FilterSheet(),
    ),
  );
}

/// Sheet content for a [FilterCubit] provided above it. The sections scroll;
/// "Set Filter" stays at the bottom.
///
/// Figma's Bedrooms, Bathrooms and Building Size controls are left out: the
/// API has no such fields (Q4, Q14).
class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FilterCubit>();
    final horizontal = AppSizes.screenHorizontalPadding.w;
    final overhang = FilterSheetHeader.overhang;
    final bottom = math.max(
      MediaQuery.viewPaddingOf(context).bottom + AppSizes.filterButtonBottom.h,
      AppSizes.sectionGap.h,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: math.max(0, AppSizes.filterSheetTop.h - overhang),
              bottom: AppSizes.filterSectionGap.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: math.max(0, horizontal - overhang),
                  ),
                  child: FilterSheetHeader(onReset: cubit.reset),
                ),
                SizedBox(
                  height: math.max(
                    0,
                    AppSizes.filterTitleSectionsGap.h - overhang,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [FilterPriceSection(), FilterCategorySection()],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            horizontal,
            0,
            horizontal,
            bottom,
          ),
          child: AppButton(
            label: context.tr(AppTextKeys.filterApply),
            onPressed: () => Navigator.of(context).pop(cubit.state.filter),
          ),
        ),
      ],
    );
  }
}
