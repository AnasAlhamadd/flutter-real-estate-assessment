import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/data/datasource/property_extras_mock_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/sample_properties.dart';

const _failure = NetworkFailure();
final PropertyEntity _listing = sampleProperties.first;
const _extras = PropertyExtrasMockDataSource.sample;

void main() {
  late MockGetPropertyDetailsUseCase getDetails;
  late MockGetPropertyExtrasUseCase getExtras;

  setUpAll(() {
    registerFallbackValue(const PropertyDetailsParams(id: 0));
  });

  setUp(() {
    getDetails = MockGetPropertyDetailsUseCase();
    when(
      () => getDetails(any()),
    ).thenAnswer((_) async => Right(sampleDetailedProperty));
    getExtras = MockGetPropertyExtrasUseCase();
    when(() => getExtras(any())).thenAnswer((_) async => const Right(_extras));
  });

  PropertyDetailsCubit build() => PropertyDetailsCubit(
    getPropertyDetails: getDetails,
    getPropertyExtras: getExtras,
  );

  test('starts in the initial state', () {
    expect(build().state, const PropertyDetailsState());
  });

  blocTest<PropertyDetailsCubit, PropertyDetailsState>(
    'shows the listing item while loading, then the full details',
    build: build,
    act: (cubit) => cubit.load(1, initial: _listing),
    expect: () => [
      PropertyDetailsState(status: RequestStatus.loading, property: _listing),
      PropertyDetailsState(
        status: RequestStatus.success,
        property: sampleDetailedProperty,
        extras: _extras,
      ),
    ],
    verify: (_) {
      verify(() => getDetails(const PropertyDetailsParams(id: 1))).called(1);
      verify(() => getExtras(const PropertyDetailsParams(id: 1))).called(1);
    },
  );

  blocTest<PropertyDetailsCubit, PropertyDetailsState>(
    'an extras failure only drops the extras',
    setUp: () => when(
      () => getExtras(any()),
    ).thenAnswer((_) async => const Left(UnknownFailure())),
    build: build,
    act: (cubit) => cubit.load(1, initial: _listing),
    expect: () => [
      PropertyDetailsState(status: RequestStatus.loading, property: _listing),
      PropertyDetailsState(
        status: RequestStatus.success,
        property: sampleDetailedProperty,
      ),
    ],
  );

  blocTest<PropertyDetailsCubit, PropertyDetailsState>(
    'ignores initial data for another id',
    build: build,
    act: (cubit) => cubit.load(1, initial: sampleProperties[2]),
    expect: () => [
      const PropertyDetailsState(status: RequestStatus.loading),
      PropertyDetailsState(
        status: RequestStatus.success,
        property: sampleDetailedProperty,
        extras: _extras,
      ),
    ],
  );

  blocTest<PropertyDetailsCubit, PropertyDetailsState>(
    'a failure keeps the listing item',
    setUp: () => when(
      () => getDetails(any()),
    ).thenAnswer((_) async => const Left(_failure)),
    build: build,
    act: (cubit) => cubit.load(1, initial: _listing),
    expect: () => [
      PropertyDetailsState(status: RequestStatus.loading, property: _listing),
      PropertyDetailsState(
        status: RequestStatus.failure,
        property: _listing,
        failure: _failure,
      ),
    ],
  );

  blocTest<PropertyDetailsCubit, PropertyDetailsState>(
    'a failure without initial data has no property',
    setUp: () => when(
      () => getDetails(any()),
    ).thenAnswer((_) async => const Left(NotFoundFailure())),
    build: build,
    act: (cubit) => cubit.load(999),
    expect: () => [
      const PropertyDetailsState(status: RequestStatus.loading),
      const PropertyDetailsState(
        status: RequestStatus.failure,
        failure: NotFoundFailure(),
      ),
    ],
  );

  blocTest<PropertyDetailsCubit, PropertyDetailsState>(
    'retry repeats the request and clears the failure',
    build: build,
    seed: () => PropertyDetailsState(
      status: RequestStatus.failure,
      property: _listing,
      failure: _failure,
    ),
    act: (cubit) async {
      when(
        () => getDetails(any()),
      ).thenAnswer((_) async => const Left(_failure));
      await cubit.load(1, initial: _listing);
      when(
        () => getDetails(any()),
      ).thenAnswer((_) async => Right(sampleDetailedProperty));
      await cubit.retry();
    },
    skip: 2,
    expect: () => [
      PropertyDetailsState(status: RequestStatus.loading, property: _listing),
      PropertyDetailsState(
        status: RequestStatus.success,
        property: sampleDetailedProperty,
        extras: _extras,
      ),
    ],
    verify: (_) => verify(() => getDetails(any())).called(2),
  );

  blocTest<PropertyDetailsCubit, PropertyDetailsState>(
    'retry does nothing before the first load',
    build: build,
    act: (cubit) => cubit.retry(),
    expect: () => <PropertyDetailsState>[],
    verify: (_) => verifyNever(() => getDetails(any())),
  );

  test('retry is ignored while a request is running', () async {
    final pending = Completer<Either<Failure, PropertyEntity>>();
    when(() => getDetails(any())).thenAnswer((_) => pending.future);
    final cubit = build();

    final load = cubit.load(1);
    await cubit.retry();
    pending.complete(Right(sampleDetailedProperty));
    await load;

    verify(() => getDetails(any())).called(1);
    await cubit.close();
  });

  test('a response after close is dropped', () async {
    final pending = Completer<Either<Failure, PropertyEntity>>();
    when(() => getDetails(any())).thenAnswer((_) => pending.future);
    final cubit = build();

    final load = cubit.load(1);
    await cubit.close();
    pending.complete(Right(sampleDetailedProperty));

    await expectLater(load, completes);
    expect(cubit.state.status, RequestStatus.loading);
  });
}
