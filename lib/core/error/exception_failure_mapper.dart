import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';

/// Used by repositories to turn anything a data source throws into a [Failure].
Failure failureFromException(Object error) => switch (error) {
  NetworkException() => const NetworkFailure(),
  RequestTimeoutException() => const TimeoutFailure(),
  ServerException(statusCode: 404) => const NotFoundFailure(),
  ServerException(:final int statusCode)
      when statusCode >= 400 && statusCode < 500 =>
    RequestFailure(statusCode: statusCode),
  ServerException(:final statusCode) => ServerFailure(statusCode: statusCode),
  ParsingException() => const UnexpectedResponseFailure(),
  CacheException() => const CacheFailure(),
  RequestCancelledException() => const CancelledFailure(),
  _ => const UnknownFailure(),
};
