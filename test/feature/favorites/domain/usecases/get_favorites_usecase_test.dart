import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_favorites_repository.dart';
import '../../../../helpers/sample_properties.dart';

void main() {
  test('returns the favorites from the repository', () async {
    final repository = FakeFavoritesRepository(saved: [sampleProperties.first]);

    final result = await GetFavoritesUseCase(repository)(const NoParams());

    expect(result.toOption().toNullable(), [sampleProperties.first]);
  });

  test('passes a repository failure through', () async {
    final repository = FakeFavoritesRepository()
      ..loadFailure = const CacheFailure();

    final result = await GetFavoritesUseCase(repository)(const NoParams());

    expect(result, const Left(CacheFailure()));
  });
}
