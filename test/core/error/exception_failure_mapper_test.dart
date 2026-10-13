import 'package:flutter_real_estate_assessment/core/error/exception_failure_mapper.dart';
import 'package:flutter_real_estate_assessment/core/error/exceptions.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = <Object, Failure>{
    const NetworkException(): const NetworkFailure(),
    const RequestTimeoutException(): const TimeoutFailure(),
    const ServerException(statusCode: 404): const NotFoundFailure(),
    const ServerException(statusCode: 400): const RequestFailure(
      statusCode: 400,
    ),
    const ServerException(statusCode: 429): const RequestFailure(
      statusCode: 429,
    ),
    const ServerException(statusCode: 500): const ServerFailure(
      statusCode: 500,
    ),
    const ServerException(statusCode: 503): const ServerFailure(
      statusCode: 503,
    ),
    const ServerException(): const ServerFailure(),
    const ParsingException(): const UnexpectedResponseFailure(),
    const CacheException(): const CacheFailure(),
    const RequestCancelledException(): const CancelledFailure(),
    const UnknownException(): const UnknownFailure(),
    StateError('unexpected'): const UnknownFailure(),
    const FormatException(): const UnknownFailure(),
  };

  cases.forEach((exception, failure) {
    test('maps $exception to $failure', () {
      expect(failureFromException(exception), failure);
    });
  });
}
