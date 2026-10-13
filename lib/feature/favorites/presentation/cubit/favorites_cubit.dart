import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/save_favorites_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_state.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// App-wide favorites, provided above the router so every screen shows the
/// same state for a property id.
///
/// A toggle updates the state at once and is then saved. Saves run one at a
/// time and always write the latest list; if one fails, the state goes back
/// to the last saved list and [FavoritesState.failure] is set.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required this._getFavorites,
    required this._saveFavorites,
    this._toggleFavorite = const ToggleFavoriteUseCase(),
  }) : super(const FavoritesState());

  final GetFavoritesUseCase _getFavorites;
  final SaveFavoritesUseCase _saveFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;

  Future<void>? _loading;
  Future<void> _writes = Future.value();
  List<PropertyEntity> _saved = const [];

  /// Reads the saved list once; later calls return the same future.
  Future<void> load() => _loading ??= _load();

  Future<void> toggle(PropertyEntity property) async {
    await load();
    if (isClosed) return;
    final result = _toggleFavorite(
      ToggleFavoriteParams(favorites: state.favorites, property: property),
    );
    result.fold(
      (failure) {
        emit(state.copyWith(failure: () => null));
        emit(state.copyWith(failure: () => failure));
      },
      (favorites) {
        emit(state.copyWith(favorites: favorites, failure: () => null));
        _writes = _writes.then((_) => _persistLatest());
      },
    );
    return _writes;
  }

  Future<void> _load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final result = await _getFavorites(const NoParams());
    if (isClosed) return;
    result.fold((_) => emit(state.copyWith(status: RequestStatus.failure)), (
      favorites,
    ) {
      _saved = favorites;
      emit(state.copyWith(status: RequestStatus.success, favorites: favorites));
    });
  }

  Future<void> _persistLatest() async {
    final favorites = state.favorites;
    if (identical(favorites, _saved)) return;
    final result = await _saveFavorites(SaveFavoritesParams(favorites));
    result.fold((failure) {
      if (isClosed) return;
      emit(state.copyWith(favorites: _saved, failure: () => failure));
    }, (_) => _saved = favorites);
  }
}
