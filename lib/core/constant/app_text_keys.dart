/// Translation keys for `assets/translations/{en,ar}.json`.
///
/// Every key used by the app is declared here once, so a typo becomes a
/// compile error instead of a raw key on screen. Each value must exist in both
/// JSON files (`test/core/constant/app_text_keys_test.dart`).
abstract final class AppTextKeys {
  static const String appTitle = 'app.title';

  static const String navHome = 'nav.home';
  static const String navExplore = 'nav.explore';
  static const String navProfile = 'nav.profile';

  static const String splashTagline = 'splash.tagline';

  static const String homeTitle = 'home.title';
  static const String exploreTitle = 'explore.title';
  static const String detailsTitle = 'details.title';
  static const String profileTitle = 'profile.title';

  static const String languageTitle = 'language.title';
  static const String languageEnglish = 'language.english';
  static const String languageArabic = 'language.arabic';

  static const String commonRetry = 'common.retry';
  static const String commonLoading = 'common.loading';
  static const String commonComingSoon = 'common.coming_soon';
  static const String commonSeeAll = 'common.see_all';
  static const String commonSearchHint = 'common.search_hint';
  static const String commonFilter = 'common.filter';
  static const String commonEmpty = 'common.empty';

  static const String errorsNoInternet = 'errors.no_internet';
  static const String errorsTimeout = 'errors.timeout';
  static const String errorsServer = 'errors.server';
  static const String errorsNotFound = 'errors.not_found';
  static const String errorsRequest = 'errors.request';
  static const String errorsUnexpectedResponse = 'errors.unexpected_response';
  static const String errorsNoCachedData = 'errors.no_cached_data';
  static const String errorsRequestCancelled = 'errors.request_cancelled';
  static const String errorsUnknown = 'errors.unknown';
  static const String errorsPageNotFound = 'errors.page_not_found';
}
