import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = RequestStatus.initial,
    this.favorites = const [],
    this.failure,
  });

  /// [RequestStatus.failure] means the saved list was unreadable; favorites
  /// then start empty and still work.
  final RequestStatus status;

  /// Newest first, unique ids.
  final List<PropertyEntity> favorites;

  /// The last toggle or save that failed, shown once. Cleared by the next
  /// toggle.
  final Failure? failure;

  bool isFavorite(int id) => favorites.any((favorite) => favorite.id == id);

  FavoritesState copyWith({
    RequestStatus? status,
    List<PropertyEntity>? favorites,
    ValueGetter<Failure?>? failure,
  }) => FavoritesState(
    status: status ?? this.status,
    favorites: favorites ?? this.favorites,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, favorites, failure];
}
