import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/enums/data_source.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_search_field.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/load_more_error_view.dart';
import 'package:flutter_real_estate_assessment/core/widget/load_more_scroll_listener.dart';
import 'package:flutter_real_estate_assessment/core/widget/scroll_to_top_button.dart';
import 'package:flutter_real_estate_assessment/core/widget/section_header.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/favorites_failure_listener.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/property_favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/cubit/home_state.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/featured_property_list.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/home_category_chips.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/home_header.dart';
import 'package:flutter_real_estate_assessment/feature/home/presentation/widget/section_status_view.dart';
import 'package:flutter_real_estate_assessment/feature/properties/presentation/widget/sliver_property_grid.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Home tab (Figma `1:4426`).
class HomeScreen extends StatelessWidget {
  const HomeScreen({this.clock = DateTime.now, super.key});

  /// Source of the time for the greeting.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: HomeView(clock: clock),
    );
  }
}

/// Home content for a [HomeCubit] provided above it.
class HomeView extends StatefulWidget {
  const HomeView({this.clock = DateTime.now, super.key});

  final DateTime Function() clock;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Scaffold(
      floatingActionButton: ScrollToTopButton(controller: _scrollController),
      body: SafeArea(
        bottom: false,
        child: FavoritesFailureListener(
          child: _RefreshFailureListener(
            child: RefreshIndicator(
              color: ColorsApp.primary,
              onRefresh: cubit.refresh,
              child: LoadMoreScrollListener(
                onLoadMore: cubit.loadMore,
                child: _HomeScrollView(
                  controller: _scrollController,
                  clock: widget.clock,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScrollView extends StatelessWidget {
  const _HomeScrollView({required this.controller, required this.clock});

  final ScrollController controller;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    final horizontal = AppSizes.screenHorizontalPadding.w;
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        _padded(
          horizontal,
          top: AppSizes.homeHeaderTop.h,
          child: HomeHeader(now: clock()),
        ),
        _padded(
          horizontal,
          top: AppSizes.sectionGap.h,
          child: AppSearchField(
            readOnly: true,
            onTap: () => context.go(AppRouter.explore),
          ),
        ),
        _padded(
          horizontal,
          top: AppSizes.sectionGap.h,
          child: const _HomeSectionHeader(titleKey: AppTextKeys.homeFeatured),
        ),
        _gap(AppSizes.homeSectionTitleContentGap.h),
        const SliverToBoxAdapter(child: _FeaturedSection()),
        _padded(
          horizontal,
          top: AppSizes.homeFeaturedRecommendationGap.h,
          child: const _HomeSectionHeader(
            titleKey: AppTextKeys.homeRecommendation,
          ),
        ),
        _gap(AppSizes.sectionGap.h),
        const SliverToBoxAdapter(child: _CategoryChips()),
        _gap(AppSizes.sectionGap.h),
        SliverPadding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: horizontal),
          sliver: const _RecommendationsSection(),
        ),
        _gap(AppSizes.sectionGap.h),
      ],
    );
  }

  static Widget _padded(
    double horizontal, {
    required double top,
    required Widget child,
  }) => SliverPadding(
    padding: EdgeInsetsDirectional.fromSTEB(horizontal, top, horizontal, 0),
    sliver: SliverToBoxAdapter(child: child),
  );

  static Widget _gap(double height) =>
      SliverToBoxAdapter(child: SizedBox(height: height));
}

void _openDetails(BuildContext context, PropertyEntity property) =>
    context.push(AppRouter.propertyDetailsPath(property.id), extra: property);

/// Snackbar when pull to refresh couldn't update what is already shown.
class _RefreshFailureListener extends StatelessWidget {
  const _RefreshFailureListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.isRefreshing && !current.isRefreshing,
      listener: (context, state) {
        if (!state.refreshFailed) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: CustomText(AppTextKeys.homeRefreshFailed)),
          );
      },
      child: child,
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: context.tr(titleKey),
      onSeeAll: () => context.go(AppRouter.explore),
    );
  }
}

/// `loading` covers the first load and the user's pull to refresh.
class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context) {
    final height = AppSizes.featuredCardHeight.r;
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.featuredStatus != current.featuredStatus ||
          previous.featured != current.featured ||
          previous.categories != current.categories,
      builder: (context, state) => switch (state.featuredStatus) {
        RequestStatus.initial ||
        RequestStatus.loading => const FeaturedPropertyListSkeleton(),
        RequestStatus.failure => SectionStatusView.failure(
          failure: state.featuredFailure!,
          onRetry: context.read<HomeCubit>().retryFeatured,
          minHeight: height,
        ),
        RequestStatus.empty => SectionStatusView.empty(minHeight: height),
        RequestStatus.success => FeaturedPropertyList(
          properties: state.featured,
          categoryNameFor: state.categoryNameFor,
          onTap: (property) => _openDetails(context, property),
          favoriteButtonBuilder: (property) => PropertyFavoriteButton(
            property: property,
            variant: FavoriteButtonVariant.onImage,
          ),
        ),
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedCategorySlug != current.selectedCategorySlug,
      builder: (context, state) => HomeCategoryChips(
        categories: state.categories,
        selectedSlug: state.selectedCategorySlug,
        onSelected: context.read<HomeCubit>().selectCategory,
      ),
    );
  }
}

/// `loading` covers the first load and the user's pull to refresh.
class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    final height = AppSizes.featuredCardHeight.r;
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.recommendationsStatus != current.recommendationsStatus ||
          previous.recommendations != current.recommendations ||
          previous.recommendationsSource != current.recommendationsSource ||
          previous.categories != current.categories,
      builder: (context, state) => switch (state.recommendationsStatus) {
        RequestStatus.initial ||
        RequestStatus.loading => const SliverPropertyGridSkeleton(),
        RequestStatus.failure => SliverToBoxAdapter(
          child: SectionStatusView.failure(
            failure: state.recommendationsFailure!,
            onRetry: context.read<HomeCubit>().retryRecommendations,
            minHeight: height,
          ),
        ),
        RequestStatus.empty => SliverToBoxAdapter(
          child: SectionStatusView.empty(minHeight: height),
        ),
        RequestStatus.success => SliverMainAxisGroup(
          slivers: [
            if (state.recommendationsSource == DataSource.saved)
              const _OfflineNotice(),
            SliverPropertyGrid(
              properties: state.recommendations,
              categoryNameFor: state.categoryNameFor,
              onTap: (property) => _openDetails(context, property),
              favoriteButtonBuilder: (property) =>
                  PropertyFavoriteButton(property: property),
            ),
            const _LoadMoreFooter(),
          ],
        ),
      },
    );
  }
}

/// Below the grid: a row of skeletons while the next page loads, or a retry
/// when it failed. Nothing once every page is loaded.
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.isLoadingMore != current.isLoadingMore ||
          previous.loadMoreFailure != current.loadMoreFailure,
      builder: (context, state) {
        if (state.isLoadingMore) {
          return SliverPadding(
            padding: EdgeInsets.only(top: AppSizes.gridVerticalGap.h),
            sliver: const SliverPropertyGridSkeleton(rows: 1),
          );
        }
        final failure = state.loadMoreFailure;
        return SliverToBoxAdapter(
          child: failure == null
              ? const SizedBox.shrink()
              : LoadMoreErrorView(
                  failure: failure,
                  onRetry: context.read<HomeCubit>().retryLoadMore,
                ),
        );
      },
    );
  }
}

/// Shown above the persisted "All" first page after a remote failure
/// (reference §4.5). Figma has no offline design, so it uses tokens only.
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
