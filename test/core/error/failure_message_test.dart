import 'package:flutter_real_estate_assessment/core/error/failure_message.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/translations.dart';

void main() {
  final expectedKeys = <Failure, String>{
    const NetworkFailure(): 'errors.no_internet',
    const TimeoutFailure(): 'errors.timeout',
    const ServerFailure(statusCode: 500): 'errors.server',
    const NotFoundFailure(): 'errors.not_found',
    const RequestFailure(statusCode: 400): 'errors.request',
    const UnexpectedResponseFailure(): 'errors.unexpected_response',
    const CacheFailure(): 'errors.no_cached_data',
    const CancelledFailure(): 'errors.request_cancelled',
    const UnknownFailure(): 'errors.unknown',
  };

  expectedKeys.forEach((failure, key) {
    test('$failure uses $key, translated in every locale', () {
      expect(failure.messageKey, key);
      for (final locale in AppLocalization.supportedLocales) {
        expect(translate(locale, key), isNotEmpty);
      }
    });
  });
}
