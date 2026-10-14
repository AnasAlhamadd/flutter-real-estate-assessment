import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_shimmer.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/core/widget/empty_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/load_more_error_view.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/property_favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/sliver_property_list.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_state.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_results_count.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Everything below the search field: "Found {n}", the list and its footer,
/// or the state that replaces them. Figma only has the populated state; the
/// others are built from tokens.
class SearchResultsSection extends StatelessWidget {
  const SearchResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.mode != current.mode ||
          previous.items != current.items ||
          previous.total != current.total ||
          previous.failure != current.failure ||
          previous.isFromCache != current.isFromCache ||
          previous.categories != current.categories,
      builder: (context, state) => switch (state.status) {
        RequestStatus.initial ||
        RequestStatus.loading => const _LoadingResults(),
        RequestStatus.failure => SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            failure: state.failure!,
            onRetry: context.read<SearchCubit>().retry,
          ),
        ),
        RequestStatus.empty => SliverFillRemaining(
          hasScrollBody: false,
          child: switch (state.mode) {
            SearchMode.browse => const EmptyView(),
            SearchMode.search => const EmptyView(
              messageKey: AppTextKeys.searchNoResults,
            ),
            SearchMode.filtered => const _NoFilteredResults(),
          },
        ),
        RequestStatus.success => _Results(state: state),
      },
    );
  }
}

class _LoadingResults extends StatelessWidget {
  const _LoadingResults();

  @override
  Widget build(BuildContext context) {
    final gap = AppSizes.searchSectionGap.h;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: gap, bottom: gap),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppShimmer(
                child: SkeletonTextLine(
                  style: AppTextStyles.sectionTitle,
                  widthFactor: 0.5,
                  radius: AppSizes.radiusPill.r,
                ),
              ),
            ),
          ),
        ),
        const SliverPropertyListSkeleton(count: AppSizes.searchSkeletonCount),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final gap = AppSizes.searchSectionGap.h;
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: gap, bottom: gap),
          sliver: SliverToBoxAdapter(
            child: SearchResultsCount(total: state.total),
          ),
        ),
        if (state.isFromCache) const _OfflineNotice(),
        SliverPropertyList(
          properties: state.items,
          categoryNameFor: state.categoryNameFor,
          onTap: (property) => context.push(
            AppRouter.propertyDetailsPath(property.id),
            extra: property,
          ),
          favoriteButtonBuilder: (property) => PropertyFavoriteButton(
            property: property,
            variant: FavoriteButtonVariant.listCard,
          ),
        ),
        const _LoadMoreFooter(),
      ],
    );
  }
}

/// Below the list: one skeleton card while the next page loads, or a retry
/// when it failed. Nothing once every page is loaded.
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) =>
          previous.isLoadingMore != current.isLoadingMore ||
          previous.loadMoreFailure != current.loadMoreFailure,
      builder: (context, state) {
        if (state.isLoadingMore) {
          return SliverPadding(
            padding: EdgeInsets.only(top: AppSizes.listGap.h),
            sliver: const SliverPropertyListSkeleton(count: 1),
          );
        }
        final failure = state.loadMoreFailure;
        return SliverToBoxAdapter(
          child: failure == null
              ? const SizedBox.shrink()
              : LoadMoreErrorView(
                  failure: failure,
                  onRetry: context.read<SearchCubit>().retryLoadMore,
                ),
        );
      },
    );
  }
}

/// Nothing passes the filters: says so and offers to clear them, which
/// returns to the paged listing of the same query.
class _NoFilteredResults extends StatelessWidget {
  const _NoFilteredResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.screenHorizontalPadding.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              AppTextKeys.filterNoResults,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular14,
            ),
            SizedBox(height: AppSizes.sectionGap.h),
            AppButton(
              label: context.tr(AppTextKeys.filterClear),
              onPressed: () =>
                  context.read<SearchCubit>().applyFilter(PropertyFilter.none),
            ),
          ],
        ),
      ),
    );
  }
}

/// Browse mode only: the persisted "All" first page after a remote failure
/// (reference §4.5), as on Home.
class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsetsDirectional.only(bottom: AppSizes.listGap.h),
      sliver: SliverToBoxAdapter(
        child: CustomText(
          AppTextKeys.commonOfflineSavedData,
          style: AppTextStyles.bodyRegular14,
        ),
      ),
    );
  }
}
