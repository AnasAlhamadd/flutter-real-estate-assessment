/// SVG icons exported from Figma (reference §5.4), normalized to a
/// 24×24 viewBox. Black shapes are tinted by `AppSvgIcon`; [star] keeps its
/// Figma gradient.
abstract final class ImagePath {
  static const String _svg = 'assets/svg';

  static const String arrowLeft = '$_svg/arrow_left.svg';
  static const String arrowRight = '$_svg/arrow_right.svg';
  static const String close = '$_svg/close.svg';
  static const String filter = '$_svg/filter.svg';

  /// Iconly Light-Outline Heart from the Home cards (`I1:4470;85001:13415`).
  static const String heart = '$_svg/heart.svg';

  /// Selected heart. Figma has no selected state, so this is the outer
  /// contour of [heart] filled, with its highlight arc cut out.
  static const String heartBold = '$_svg/heart_bold.svg';
  static const String homeBold = '$_svg/home_bold.svg';
  static const String homeLight = '$_svg/home_light.svg';
  static const String language = '$_svg/language.svg';
  static const String profileBold = '$_svg/profile_bold.svg';
  static const String profileLight = '$_svg/profile_light.svg';
  static const String search = '$_svg/search.svg';
  static const String searchBold = '$_svg/search_bold.svg';
  static const String star = '$_svg/star.svg';

  /// Details body (Figma `1:4273`): stats row, Agent actions, Location pin
  /// and the eight facilities, normalized like the icons above.
  static const String statBed = '$_svg/stat_bed.svg';
  static const String statBath = '$_svg/stat_bath.svg';
  static const String statArea = '$_svg/stat_area.svg';
  static const String chat = '$_svg/chat.svg';
  static const String call = '$_svg/call.svg';
  static const String locationBold = '$_svg/location_bold.svg';
  static const String facilityCarParking = '$_svg/facility_car_parking.svg';
  static const String facilitySwimmingPool = '$_svg/facility_swimming_pool.svg';
  static const String facilityGym = '$_svg/facility_gym.svg';
  static const String facilityRestaurant = '$_svg/facility_restaurant.svg';
  static const String facilityWifi = '$_svg/facility_wifi.svg';
  static const String facilityPetCenter = '$_svg/facility_pet_center.svg';
  static const String facilitySportCenter = '$_svg/facility_sport_center.svg';
  static const String facilityLaundry = '$_svg/facility_laundry.svg';

  /// Location map art (Figma `1:4387`, 437.011×926) and its pin (`1:4392`,
  /// 53.1365×61.4796), exported as-is with their colors; the map's
  /// full-frame alpha mask was removed.
  static const String detailsMap = '$_svg/details_map.svg';
  static const String mapPin = '$_svg/map_pin.svg';

  /// this mock: Figma sample photos (2×). The API has no agent or property
  /// pin photo, so the agent row (`I1:4310;546:5917`, 60×60) and the map
  /// pin (`1:4395`, 32.674×32) show these.
  static const String agentAvatar = 'assets/images/agent_avatar.png';
  static const String mapPinPhoto = 'assets/images/map_pin_photo.png';

  /// Splash logo (Figma `1:4553`), exported as-is: multicolor, 133.885×112.445.
  static const String splashLogo = '$_svg/splash_logo.svg';

  /// Google logo of the Auth button (Figma `1:4549`), exported as-is:
  /// multicolor, 22×22.
  static const String google = '$_svg/google.svg';

  /// Auth photo collage (Figma `1:4521`, 399×552) with its fade (`1:4541`)
  /// baked in: the Figma SVG export rendered at 3× on white, saved as WebP.
  static const String authCollage = 'assets/images/auth_collage.webp';

  /// Normalized 24×24 icons.
  static const List<String> icons = [
    arrowLeft,
    arrowRight,
    close,
    filter,
    heart,
    heartBold,
    homeBold,
    homeLight,
    language,
    profileBold,
    profileLight,
    search,
    searchBold,
    star,
    statBed,
    statBath,
    statArea,
    chat,
    call,
    locationBold,
    facilityCarParking,
    facilitySwimmingPool,
    facilityGym,
    facilityRestaurant,
    facilityWifi,
    facilityPetCenter,
    facilitySportCenter,
    facilityLaundry,
  ];
}
