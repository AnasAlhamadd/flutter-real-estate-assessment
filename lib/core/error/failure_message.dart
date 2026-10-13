import 'package:flutter_real_estate_assessment/core/error/failures.dart';

extension FailureMessage on Failure {
  /// Translation key for a user-friendly message (never raw error text, D3).
  String get messageKey => switch (this) {
    NetworkFailure() => 'errors.no_internet',
    TimeoutFailure() => 'errors.timeout',
    ServerFailure() => 'errors.server',
    NotFoundFailure() => 'errors.not_found',
    RequestFailure() => 'errors.request',
    UnexpectedResponseFailure() => 'errors.unexpected_response',
    CacheFailure() => 'errors.no_cached_data',
    CancelledFailure() => 'errors.request_cancelled',
    UnknownFailure() => 'errors.unknown',
  };
}
