import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_state.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fake_favorites_repository.dart';
import '../../../../helpers/sample_properties.dart';

final PropertyEntity _a = sampleProperties[0];
final PropertyEntity _b = sampleProperties[1];
final PropertyEntity _c = sampleProperties[2];

Future<void> _flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late FakeFavoritesRepository repository;

  setUp(() => repository = FakeFavoritesRepository());

  FavoritesCubit build() => favoritesCubitFor(repository);

  group('load', () {
    blocTest<FavoritesCubit, FavoritesState>(
      'emits the saved favorites',
      setUp: () => repository.saved = [_b, _a],
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const FavoritesState(status: RequestStatus.loading),
        FavoritesState(status: RequestStatus.success, favorites: [_b, _a]),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'reads the device only once',
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.load();
      },
      verify: (_) => expect(repository.loads, 1),
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'unreadable favorites start empty and toggling still works',
      setUp: () => repository.loadFailure = const CacheFailure(),
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.toggle(_a);
      },
      verify: (cubit) {
        expect(cubit.state.status, RequestStatus.failure);
        expect(cubit.state.favorites, [_a]);
        expect(repository.saved, [_a]);
      },
    );
  });

  group('toggle', () {
    test('shows the change before the save finishes', () async {
      final gate = Completer<void>();
      repository.saveGate = gate.future;
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();

      unawaited(cubit.toggle(_a));
      await _flush();

      expect(cubit.state.isFavorite(_a.id), isTrue);
      expect(repository.saved, isEmpty);
      gate.complete();
      await _flush();
      expect(repository.saved, [_a]);
    });

    blocTest<FavoritesCubit, FavoritesState>(
      'adds newest first and removes by id',
      build: build,
      act: (cubit) async {
        await cubit.toggle(_a);
        await cubit.toggle(_b);
        await cubit.toggle(_a);
      },
      verify: (cubit) {
        expect(cubit.state.favorites, [_b]);
        expect(cubit.state.isFavorite(_a.id), isFalse);
        expect(repository.saved, [_b]);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'keeps saved favorites when toggled before load is called',
      setUp: () => repository.saved = [_a],
      build: build,
      act: (cubit) => cubit.toggle(_b),
      verify: (cubit) {
        expect(cubit.state.favorites, [_b, _a]);
        expect(repository.saved, [_b, _a]);
      },
    );

    test('rapid taps end with the latest list on the device', () async {
      final gate = Completer<void>();
      repository.saveGate = gate.future;
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();

      final taps = [
        cubit.toggle(_a),
        cubit.toggle(_b),
        cubit.toggle(_a),
        cubit.toggle(_c),
      ];
      gate.complete();
      await Future.wait(taps);

      expect(cubit.state.favorites, [_c, _b]);
      expect(repository.saved, [_c, _b]);
      expect(repository.saves.last, [_c, _b]);
      expect(repository.saves.length, lessThanOrEqualTo(taps.length));
    });

    blocTest<FavoritesCubit, FavoritesState>(
      'a failed save goes back to the saved list and reports it',
      setUp: () {
        repository
          ..saved = [_a]
          ..saveFailure = const CacheFailure();
      },
      build: build,
      act: (cubit) => cubit.toggle(_b),
      expect: () => [
        const FavoritesState(status: RequestStatus.loading),
        FavoritesState(status: RequestStatus.success, favorites: [_a]),
        FavoritesState(status: RequestStatus.success, favorites: [_b, _a]),
        FavoritesState(
          status: RequestStatus.success,
          favorites: [_a],
          failure: const CacheFailure(),
        ),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'the next toggle clears the reported failure',
      setUp: () => repository.saveFailure = const CacheFailure(),
      build: build,
      act: (cubit) async {
        await cubit.toggle(_a);
        repository.saveFailure = null;
        await cubit.toggle(_a);
      },
      verify: (cubit) {
        expect(cubit.state.failure, isNull);
        expect(cubit.state.favorites, [_a]);
      },
    );

    test('refuses a new favorite at the limit, every time', () async {
      repository.saved = [
        for (var id = 1; id <= ToggleFavoriteUseCase.maxFavorites; id++)
          PropertyEntity(
            id: 1000 + id,
            title: '$id',
            price: 1,
            rating: 1,
            category: 'beauty',
          ),
      ];
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();
      final failures = <Failure?>[];
      final subscription = cubit.stream.listen((s) => failures.add(s.failure));
      addTearDown(subscription.cancel);

      await cubit.toggle(_a);
      await cubit.toggle(_a);
      await _flush();

      expect(failures, [
        const FavoritesLimitFailure(),
        null,
        const FavoritesLimitFailure(),
      ]);
      expect(cubit.state.isFavorite(_a.id), isFalse);
      expect(repository.saves, isEmpty);
    });

    test('closing during a save does not throw', () async {
      final gate = Completer<void>();
      repository
        ..saveGate = gate.future
        ..saveFailure = const CacheFailure();
      final cubit = build();
      await cubit.load();

      final toggle = cubit.toggle(_a);
      await cubit.close();
      gate.complete();

      await expectLater(toggle, completes);
    });
  });

  test('favorites survive an app restart', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    FavoritesCubit launch() => favoritesCubitFor(
      FavoritesRepositoryImpl(FavoritesLocalDataSourceImpl(preferences)),
    );

    final first = launch();
    await first.toggle(_a);
    await first.toggle(_c);
    await first.close();

    final second = launch();
    addTearDown(second.close);
    await second.load();

    expect(second.state.favorites, [_c, _a]);
  });
}
