import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';

extension FailureMessage on Failure {
  /// Translation key for a user-friendly message (never raw error text, D3).
  String get messageKey => switch (this) {
    NetworkFailure() => AppTextKeys.errorsNoInternet,
    TimeoutFailure() => AppTextKeys.errorsTimeout,
    ServerFailure() => AppTextKeys.errorsServer,
    NotFoundFailure() => AppTextKeys.errorsNotFound,
    RequestFailure() => AppTextKeys.errorsRequest,
    UnexpectedResponseFailure() => AppTextKeys.errorsUnexpectedResponse,
    CacheFailure() => AppTextKeys.errorsNoCachedData,
    FavoritesLimitFailure() => AppTextKeys.favoritesLimitReached,
    CancelledFailure() => AppTextKeys.errorsRequestCancelled,
    UnknownFailure() => AppTextKeys.errorsUnknown,
  };
}
