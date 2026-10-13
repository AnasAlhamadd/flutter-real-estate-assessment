/// SVG icons exported from Figma (reference §5.4), normalized to a
/// 24×24 viewBox. Black shapes are tinted by `AppSvgIcon`; [star] keeps its
/// Figma gradient.
abstract final class ImagePath {
  static const String _svg = 'assets/svg';

  static const String arrowLeft = '$_svg/arrow_left.svg';
  static const String arrowRight = '$_svg/arrow_right.svg';
  static const String filter = '$_svg/filter.svg';
  static const String homeBold = '$_svg/home_bold.svg';
  static const String homeLight = '$_svg/home_light.svg';
  static const String language = '$_svg/language.svg';
  static const String profileBold = '$_svg/profile_bold.svg';
  static const String profileLight = '$_svg/profile_light.svg';
  static const String search = '$_svg/search.svg';
  static const String searchBold = '$_svg/search_bold.svg';
  static const String star = '$_svg/star.svg';

  /// Splash logo (Figma `1:4553`), exported as-is: multicolor, 133.885×112.445.
  static const String splashLogo = '$_svg/splash_logo.svg';

  /// Normalized 24×24 icons.
  static const List<String> icons = [
    arrowLeft,
    arrowRight,
    filter,
    homeBold,
    homeLight,
    language,
    profileBold,
    profileLight,
    search,
    searchBold,
    star,
  ];
}
