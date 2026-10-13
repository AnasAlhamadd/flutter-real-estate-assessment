import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_test/flutter_test.dart';

PropertyEntity _item(int id) => PropertyEntity(
  id: id,
  title: 'Item $id',
  price: 1,
  rating: 1,
  category: 'beauty',
);

void main() {
  group('ToggleFavoriteUseCase', () {
    const toggle = ToggleFavoriteUseCase();

    List<int> ids(Either<Failure, List<PropertyEntity>> result) => result
        .getOrElse(() => fail('expected a list'))
        .map((p) => p.id)
        .toList();

    test('adds a new favorite first', () {
      final result = toggle(
        ToggleFavoriteParams(favorites: [_item(1)], property: _item(2)),
      );

      expect(ids(result), [2, 1]);
    });

    test('removes a favorite matched by id, not by the whole object', () {
      const sameIdOtherData = PropertyEntity(
        id: 1,
        title: 'From details',
        price: 99,
        rating: 5,
        category: 'beauty',
        description: 'Loaded by the details screen',
      );

      final result = toggle(
        ToggleFavoriteParams(
          favorites: [_item(2), _item(1)],
          property: sameIdOtherData,
        ),
      );

      expect(ids(result), [2]);
    });

    test('refuses to add beyond the limit but still removes', () {
      final full = [
        for (var id = 1; id <= ToggleFavoriteUseCase.maxFavorites; id++)
          _item(id),
      ];

      expect(
        toggle(ToggleFavoriteParams(favorites: full, property: _item(999))),
        const Left(FavoritesLimitFailure()),
      );
      expect(
        ids(toggle(ToggleFavoriteParams(favorites: full, property: _item(1)))),
        hasLength(ToggleFavoriteUseCase.maxFavorites - 1),
      );
    });

    test('returns a new list and leaves the input unchanged', () {
      final current = [_item(1)];

      final result = toggle(
        ToggleFavoriteParams(favorites: current, property: _item(2)),
      );

      expect(current.map((p) => p.id), [1]);
      expect(
        () => result.getOrElse(() => []).add(_item(3)),
        throwsUnsupportedError,
      );
    });
  });
}
