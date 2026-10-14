import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/core/utils/cancellation_signal.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/search_properties_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/price_histogram.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_state.dart';

/// Filter sheet (Figma `1:3867`): draft category and price choices over the
/// full matching set of the Explore query.
///
/// The full set it loads stays in the repository's memory, so "Set Filter"
/// usually needs no second request. Closing the sheet cancels a load still
/// in flight.
class FilterCubit extends Cubit<FilterState> {
  FilterCubit({required this._getAllMatches, required this._getCategories})
    : super(const FilterState());

  final SearchPropertiesUseCase _getAllMatches;
  final GetCategoriesUseCase _getCategories;

  CancellationSignal? _cancellation;
  String _query = '';

  /// Starts from the [applied] filter for [query] (normalized; empty for the
  /// whole catalog).
  Future<void> load({
    required String query,
    PropertyFilter applied = PropertyFilter.none,
  }) async {
    _query = query;
    emit(
      FilterState(
        selectedCategories: applied.categorySlugs,
        initialPriceRange: applied.priceRange,
      ),
    );
    await Future.wait([_loadCategories(), _loadPrices()]);
  }

  /// Retries a failed price load.
  Future<void> retry() async {
    if (state.priceStatus != RequestStatus.failure) return;
    await Future.wait([
      if (state.categories.isEmpty) _loadCategories(),
      _loadPrices(),
    ]);
  }

  void toggleCategory(String slug) {
    final selected = {...state.selectedCategories};
    if (!selected.remove(slug)) selected.add(slug);
    emit(state.copyWith(selectedCategories: Set.unmodifiable(selected)));
  }

  /// Slider positions (0–1) on the histogram's scale.
  void setPriceRange(double start, double end) {
    if (state.histogram == null) return;
    emit(state.copyWith(rangeStart: start, rangeEnd: end));
  }

  /// Every category and the whole price range. Applied on "Set Filter".
  void reset() {
    emit(
      state.copyWith(
        selectedCategories: const {},
        initialPriceRange: () => null,
        rangeStart: 0,
        rangeEnd: 1,
      ),
    );
  }

  @override
  Future<void> close() {
    _cancellation?.cancel();
    return super.close();
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories(const NoParams());
    if (isClosed) return;
    result.fold((_) {}, (categories) {
      emit(state.copyWith(categories: categories));
    });
  }

  Future<void> _loadPrices() async {
    _cancellation?.cancel();
    final cancellation = _cancellation = CancellationSignal();
    emit(
      state.copyWith(priceStatus: RequestStatus.loading, failure: () => null),
    );
    final result = await _getAllMatches(
      SearchParams(query: _query, cancellation: cancellation),
    );
    if (isClosed || cancellation.isCancelled) return;
    result.fold(
      (failure) {
        if (failure is CancelledFailure) return;
        emit(
          state.copyWith(
            priceStatus: RequestStatus.failure,
            failure: () => failure,
          ),
        );
      },
      (page) {
        final histogram = PriceHistogram.of(
          page.items.map((item) => item.price),
        );
        final positions = histogram.positionsOf(state.initialPriceRange);
        emit(
          state.copyWith(
            priceStatus: RequestStatus.success,
            histogram: () => histogram,
            rangeStart: positions.start,
            rangeEnd: positions.end,
          ),
        );
      },
    );
  }
}
