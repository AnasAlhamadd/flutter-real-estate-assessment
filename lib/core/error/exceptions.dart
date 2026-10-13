import 'package:equatable/equatable.dart';

/// Thrown by data sources only. Repositories convert these into [Failure]s.
sealed class AppException extends Equatable implements Exception {
  const AppException();

  @override
  List<Object?> get props => [];
}

final class ServerException extends AppException {
  const ServerException({this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

final class NetworkException extends AppException {
  const NetworkException();
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException();
}

final class ParsingException extends AppException {
  const ParsingException();
}

final class CacheException extends AppException {
  const CacheException();
}

final class RequestCancelledException extends AppException {
  const RequestCancelledException();
}

final class UnknownException extends AppException {
  const UnknownException();
}
