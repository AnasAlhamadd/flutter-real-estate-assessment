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
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_header.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/search_results_section.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Explore tab (Figma `1:4120`, "Search-v1"). The category chips and the
/// filter icon wait for the Filter task; the bell is hidden (Q13).
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
            child: RefreshIndicator(
              color: ColorsApp.primary,
              onRefresh: cubit.refresh,
              child: LoadMoreScrollListener(
                onLoadMore: cubit.loadMore,
                child: _SearchScrollView(
                  scrollController: _scrollController,
                  queryController: _queryController,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchScrollView extends StatelessWidget {
  const _SearchScrollView({
    required this.scrollController,
    required this.queryController,
  });

  final ScrollController scrollController;
  final TextEditingController queryController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final horizontal = AppSizes.screenHorizontalPadding.w;
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        _padded(
          horizontal,
          top: AppSizes.searchHeaderTop.h,
          child: SearchHeader(onBack: () => context.go(AppRouter.home)),
        ),
        _padded(
          horizontal,
          top: AppSizes.sectionGap.h,
          child: AppSearchField(
            controller: queryController,
            onChanged: cubit.onQueryChanged,
            onSubmitted: cubit.submitQuery,
          ),
        ),
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

  static Widget _padded(
    double horizontal, {
    required double top,
    required Widget child,
  }) => SliverPadding(
    padding: EdgeInsetsDirectional.fromSTEB(horizontal, top, horizontal, 0),
    sliver: SliverToBoxAdapter(child: child),
  );
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
