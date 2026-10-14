import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_router.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_search_field.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/core/widget/load_more_scroll_listener.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/favorites_failure_listener.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/search_state.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/filter_sheet.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_header.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_results_section.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Explore tab (Figma `1:4120`, "Search-v1"). The filter icon opens the
/// Filter sheet (`1:3867`); the bell is hidden (Q13).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>()..load(),
      child: const SearchView(),
    );
  }
}

/// Explore content for a [SearchCubit] provided above it. The tab stays
/// mounted, so the query, results and scroll position survive Details.
///
/// Not in Figma: the header and search field stay pinned and the results
/// scroll under them; pull to refresh belongs to the results only, so its
/// spinner starts below the field (reference §4.10 U7).
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FavoritesFailureListener(
          child: _RefreshFailureListener(
            child: Column(
              children: [
                _SearchTopBar(queryController: _queryController),
                Expanded(
                  child: RefreshIndicator(
                    color: ColorsApp.primary,
                    onRefresh: cubit.refresh,
                    child: LoadMoreScrollListener(
                      onLoadMore: cubit.loadMore,
                      child: _ResultsScrollView(
                        scrollController: _scrollController,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header and search field, pinned above the results.
class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar({required this.queryController});

  final TextEditingController queryController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final horizontal = AppSizes.screenHorizontalPadding.w;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        horizontal,
        AppSizes.searchHeaderTop.h,
        horizontal,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchHeader(onBack: () => context.go(AppRouter.home)),
          SizedBox(height: AppSizes.sectionGap.h),
          BlocSelector<SearchCubit, SearchState, bool>(
            selector: (state) => state.filter.isActive,
            builder: (context, filterActive) => AppSearchField(
              controller: queryController,
              onChanged: cubit.onQueryChanged,
              onSubmitted: cubit.submitQuery,
              onFilterTap: () => _openFilter(context),
              filterActive: filterActive,
            ),
          ),
        ],
      ),
    );
  }

  /// The sheet describes the latest typed query, even one still waiting for
  /// the debounce, so applying it never shows another query's results.
  static Future<void> _openFilter(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final cubit = context.read<SearchCubit>();
    final filter = await showFilterSheet(
      context,
      query: cubit.requestedQuery,
      applied: cubit.state.filter,
    );
    if (filter == null || cubit.isClosed) return;
    await cubit.applyFilter(filter);
  }
}

/// "Found {n}", the results and their footer, scrolling under the top bar.
class _ResultsScrollView extends StatelessWidget {
  const _ResultsScrollView({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final horizontal = AppSizes.screenHorizontalPadding.w;
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(
            horizontal,
            0,
            horizontal,
            AppSizes.sectionGap.h,
          ),
          sliver: const SearchResultsSection(),
        ),
      ],
    );
  }
}

/// Snackbar when a refresh couldn't update the results already shown.
class _RefreshFailureListener extends StatelessWidget {
  const _RefreshFailureListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchCubit, SearchState>(
      listenWhen: (previous, current) =>
          previous.isRefreshing && !current.isRefreshing,
      listener: (context, state) {
        if (!state.refreshFailed) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: CustomText(AppTextKeys.searchRefreshFailed),
            ),
          );
      },
      child: child,
    );
  }
}
