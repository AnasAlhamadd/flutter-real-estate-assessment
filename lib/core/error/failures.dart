import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

final class RequestFailure extends Failure {
  const RequestFailure({required this.statusCode});

  final int statusCode;

  @override
  List<Object?> get props => [statusCode];
}

final class UnexpectedResponseFailure extends Failure {
  const UnexpectedResponseFailure();
}

final class CacheFailure extends Failure {
  const CacheFailure();
}

/// The saved favorites list is full (`ToggleFavoriteUseCase.maxFavorites`).
final class FavoritesLimitFailure extends Failure {
  const FavoritesLimitFailure();
}

/// A superseded request (e.g. a newer search query). Never shown to the user.
final class CancelledFailure extends Failure {
  const CancelledFailure();
}

final class UnknownFailure extends Failure {
  const UnknownFailure();
}
