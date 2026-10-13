import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/save_favorites_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_favorites_repository.dart';
import '../../../../helpers/sample_properties.dart';

void main() {
  test('saves the given list through the repository', () async {
    final repository = FakeFavoritesRepository();

    final result = await SaveFavoritesUseCase(repository)(
      SaveFavoritesParams([sampleProperties.last]),
    );

    expect(result, const Right(unit));
    expect(repository.saved, [sampleProperties.last]);
  });

  test('passes a repository failure through', () async {
    final repository = FakeFavoritesRepository()
      ..saveFailure = const CacheFailure();

    final result = await SaveFavoritesUseCase(repository)(
      const SaveFavoritesParams([]),
    );

    expect(result, const Left(CacheFailure()));
  });
}
