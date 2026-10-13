import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFavoritesLocalDataSource local;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    local = MockFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(local);
  });

  const listing = PropertyModel(
    id: 7,
    title: 'Loft',
    price: 1200,
    rating: 4.2,
    category: 'furniture',
    brand: 'Brand',
    thumbnailUrl: 'https://cdn.dummyjson.com/7/thumbnail.webp',
  );

  group('getFavorites', () {
    test('maps saved listings to entities', () async {
      when(() => local.getFavorites()).thenAnswer((_) async => [listing]);

      final result = await repository.getFavorites();

      expect(result.toOption().toNullable(), [listing.toEntity()]);
    });

    test('unreadable data becomes a CacheFailure', () async {
      when(() => local.getFavorites()).thenThrow(const CacheException());

      expect(await repository.getFavorites(), const Left(CacheFailure()));
    });
  });

  group('saveFavorites', () {
    test('saves only the listing fields', () async {
      when(() => local.saveFavorites(any())).thenAnswer((_) async {});
      const details = PropertyEntity(
        id: 7,
        title: 'Loft',
        price: 1200,
        rating: 4.2,
        category: 'furniture',
        brand: 'Brand',
        thumbnailUrl: 'https://cdn.dummyjson.com/7/thumbnail.webp',
        description: 'Long description',
        stock: 3,
        tags: ['tag'],
        imageUrls: ['https://cdn.dummyjson.com/7/1.webp'],
      );

      expect(await repository.saveFavorites([details]), const Right(unit));

      final saved =
          verify(() => local.saveFavorites(captureAny())).captured.single
              as List<PropertyModel>;
      expect(saved.single.toJson(), listing.toJson());
    });

    test('a failed write becomes a CacheFailure', () async {
      when(() => local.saveFavorites(any())).thenThrow(const CacheException());

      expect(
        await repository.saveFavorites(const []),
        const Left(CacheFailure()),
      );
    });
  });
}
