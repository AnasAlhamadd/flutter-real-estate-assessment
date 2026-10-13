import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/save_favorites_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// In-memory [FavoritesRepository]. [saveFailure] makes every save fail;
/// [saveGate] holds saves until it completes.
class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository({this.saved = const []});

  List<PropertyEntity> saved;
  Failure? loadFailure;
  Failure? saveFailure;
  Future<void>? saveGate;

  /// Every list passed to [saveFavorites], in call order.
  final List<List<PropertyEntity>> saves = [];
  int loads = 0;

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFavorites() async {
    loads++;
    final failure = loadFailure;
    return failure == null ? Right(saved) : Left(failure);
  }

  @override
  Future<Either<Failure, Unit>> saveFavorites(
    List<PropertyEntity> favorites,
  ) async {
    saves.add(favorites);
    await saveGate;
    final failure = saveFailure;
    if (failure != null) return Left(failure);
    saved = favorites;
    return const Right(unit);
  }
}

FavoritesCubit favoritesCubitFor(FavoritesRepository repository) =>
    FavoritesCubit(
      getFavorites: GetFavoritesUseCase(repository),
      saveFavorites: SaveFavoritesUseCase(repository),
    );
