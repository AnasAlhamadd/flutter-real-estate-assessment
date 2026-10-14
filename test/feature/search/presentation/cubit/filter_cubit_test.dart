import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/price_histogram.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/property_filter.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/cubit/filter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_home_repository.dart';
import '../../../../helpers/fake_properties_repository.dart';
import '../../../../helpers/fake_search_repository.dart';

void main() {
  final samplePrices = PriceHistogram.of(
    sampleProperties.map((item) => item.price),
  );

  late FakePropertiesRepository properties;
  late FakeHomeRepository home;
  late FilterCubit cubit;

  setUp(() {
    properties = FakePropertiesRepository();
    home = FakeHomeRepository();
    cubit = filterCubitFor(properties, home);
  });

  tearDown(() => cubit.close());

  test(
    'loads the categories and the price distribution of the query',
    () async {
      await cubit.load(query: 'mirror');

      expect(properties.fullSetRequests, ['mirror']);
      expect(cubit.state.categories, sampleCategories);
      expect(cubit.state.priceStatus, RequestStatus.success);
      expect(cubit.state.histogram, PriceHistogram.of(const [19.99, 799.99]));
      expect(cubit.state.filter, PropertyFilter.none);
    },
  );

  test('without a query, loads the whole catalog', () async {
    await cubit.load(query: '');

    expect(properties.fullSetRequests, ['']);
    expect(cubit.state.histogram, samplePrices);
    expect((cubit.state.rangeStart, cubit.state.rangeEnd), (0.0, 1.0));
  });

  test('starts from the applied filter', () async {
    const applied = PropertyFilter(
      categorySlugs: {'beauty'},
      priceRange: PriceRange(min: 0, max: 100),
    );

    await cubit.load(query: '', applied: applied);

    expect(cubit.state.selectedCategories, {'beauty'});
    expect(cubit.state.rangeStart, 0);
    expect(cubit.state.rangeEnd, samplePrices.positionOf(100));
    expect(cubit.state.filter, applied);
  });

  test('keeps the applied price range while prices load', () async {
    final gate = Completer<void>();
    properties.fullSetGate = gate.future;
    const applied = PropertyFilter(
      priceRange: PriceRange(min: 50, max: double.infinity),
    );

    final loading = cubit.load(query: '', applied: applied);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.priceStatus, RequestStatus.loading);
    expect(cubit.state.filter, applied);
    gate.complete();
    await loading;
  });

  test('a failed price load can be retried', () async {
    properties.fullSets = {'': const Left(NetworkFailure())};
    await cubit.load(query: '');

    expect(cubit.state.priceStatus, RequestStatus.failure);
    expect(cubit.state.failure, const NetworkFailure());
    expect(cubit.state.categories, sampleCategories);

    properties.fullSets = {};
    await cubit.retry();

    expect(properties.fullSetRequests, ['', '']);
    expect(cubit.state.priceStatus, RequestStatus.success);
    expect(cubit.state.failure, isNull);
  });

  test('toggles categories on and off', () async {
    await cubit.load(query: '');

    cubit
      ..toggleCategory('beauty')
      ..toggleCategory('furniture');
    expect(cubit.state.filter.categorySlugs, {'beauty', 'furniture'});

    cubit.toggleCategory('beauty');
    expect(cubit.state.filter.categorySlugs, {'furniture'});
  });

  test('slider positions become an open-ended price range', () async {
    cubit.setPriceRange(0.5, 1);
    expect(cubit.state.rangeStart, 0, reason: 'ignored before prices load');

    await cubit.load(query: '');
    cubit.setPriceRange(0.5, 1);

    expect(
      cubit.state.filter.priceRange,
      PriceRange(min: samplePrices.priceAt(0.5), max: double.infinity),
    );

    cubit.setPriceRange(0, 1);
    expect(cubit.state.filter, PropertyFilter.none);
  });

  test('reset clears categories and prices', () async {
    await cubit.load(
      query: '',
      applied: const PropertyFilter(
        categorySlugs: {'beauty'},
        priceRange: PriceRange(min: 20, max: 100),
      ),
    );

    cubit.reset();

    expect(cubit.state.filter, PropertyFilter.none);
    expect((cubit.state.rangeStart, cubit.state.rangeEnd), (0.0, 1.0));
    expect(cubit.state.histogram, samplePrices);
  });

  test('closing while prices load ignores the late response', () async {
    final gate = Completer<void>();
    properties.fullSetGate = gate.future;

    final loading = cubit.load(query: '');
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    gate.complete();
    await loading;

    expect(cubit.state.priceStatus, RequestStatus.loading);
  });
}
