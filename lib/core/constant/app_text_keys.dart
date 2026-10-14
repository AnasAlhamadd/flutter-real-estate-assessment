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

  static const String authWelcome = 'auth.welcome';
  static const String authHeadline = 'auth.headline';
  static const String authHeadlineHighlight = 'auth.headline_highlight';
  static const String authSubtitle = 'auth.subtitle';
  static const String authGoogleButton = 'auth.google_button';
  static const String authSignInUnavailable = 'auth.sign_in_unavailable';
  static const String authContinueAsGuest = 'auth.continue_as_guest';

  static const String homeGoodMorning = 'home.good_morning';
  static const String homeGoodAfternoon = 'home.good_afternoon';
  static const String homeGoodEvening = 'home.good_evening';
  static const String homeWelcomeGuest = 'home.welcome_guest';
  static const String homeFeatured = 'home.featured';
  static const String homeRecommendation = 'home.recommendation';
  static const String homeRefreshFailed = 'home.refresh_failed';

  static const String favoritesAdd = 'favorites.add';
  static const String favoritesRemove = 'favorites.remove';
  static const String favoritesLimitReached = 'favorites.limit_reached';
  static const String favoritesSaveFailed = 'favorites.save_failed';

  static const String exploreTitle = 'explore.title';

  /// Plural: "Found {} results".
  static const String searchFound = 'search.found';
  static const String searchNoResults = 'search.no_results';
  static const String searchRefreshFailed = 'search.refresh_failed';

  static const String filterReset = 'filter.reset';
  static const String filterPriceRange = 'filter.price_range';
  static const String filterPropertyType = 'filter.property_type';
  static const String filterApply = 'filter.apply';
  static const String filterActive = 'filter.active';
  static const String filterNoResults = 'filter.no_results';
  static const String filterClear = 'filter.clear';
  static const String filterPriceChart = 'filter.price_chart';
  static const String profileTitle = 'profile.title';

  static const String detailsOverview = 'details.overview';
  static const String detailsGallery = 'details.gallery';
  static const String detailsPrice = 'details.price';

  /// Plural; named arg `rating`.
  static const String detailsRatingReviews = 'details.rating_reviews';

  /// Named args `index`, `total`.
  static const String detailsImagePosition = 'details.image_position';
  static const String detailsShowImage = 'details.show_image';

  /// Plurals.
  static const String detailsBeds = 'details.beds';
  static const String detailsBaths = 'details.baths';
  static const String detailsReviewLikes = 'details.review_likes';

  /// Named arg `area`.
  static const String detailsArea = 'details.area';
  static const String detailsAgent = 'details.agent';
  static const String detailsAgentRoleOwner = 'details.agent_role_owner';

  /// Named arg `name`.
  static const String detailsChatAgent = 'details.chat_agent';
  static const String detailsCallAgent = 'details.call_agent';
  static const String detailsFacilities = 'details.facilities';
  static const String facilityCarParking = 'details.facility.car_parking';
  static const String facilitySwimmingPool = 'details.facility.swimming_pool';
  static const String facilityGym = 'details.facility.gym';
  static const String facilityRestaurant = 'details.facility.restaurant';
  static const String facilityWifi = 'details.facility.wifi';
  static const String facilityPetCenter = 'details.facility.pet_center';
  static const String facilitySportCenter = 'details.facility.sport_center';
  static const String facilityLaundry = 'details.facility.laundry';
  static const String detailsLocation = 'details.location';
  static const String detailsMap = 'details.map';
  static const String detailsBookingNow = 'details.booking_now';
  static const String detailsNotAvailable = 'details.not_available';
  static const String detailsCallFailed = 'details.call_failed';

  static const String timeJustNow = 'time.just_now';

  /// Plurals.
  static const String timeMinutesAgo = 'time.minutes_ago';
  static const String timeHoursAgo = 'time.hours_ago';
  static const String timeDaysAgo = 'time.days_ago';
  static const String timeMonthsAgo = 'time.months_ago';
  static const String timeYearsAgo = 'time.years_ago';

  static const String languageTitle = 'language.title';
  static const String languageEnglish = 'language.english';
  static const String languageArabic = 'language.arabic';

  static const String commonRetry = 'common.retry';
  static const String commonLoading = 'common.loading';
  static const String commonComingSoon = 'common.coming_soon';
  static const String commonSeeAll = 'common.see_all';
  static const String commonSearchHint = 'common.search_hint';
  static const String commonClearSearch = 'common.clear_search';
  static const String commonFilter = 'common.filter';
  static const String commonEmpty = 'common.empty';
  static const String commonAll = 'common.all';
  static const String commonOfflineSavedData = 'common.offline_saved_data';
  static const String commonBackToTop = 'common.back_to_top';

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
