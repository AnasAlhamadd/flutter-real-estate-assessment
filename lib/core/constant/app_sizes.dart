import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';

/// Figma spacing, sizes, radii and shadows in design pixels (reference §5.3).
/// Widgets scale them with ScreenUtil (`.w`, `.h`, `.r`).
///
/// Values marked [S] are measured from the 1x Figma frame exports because
/// §5.3 doesn't list them.
abstract final class AppSizes {
  static const Size designSize = Size(430, 932);

  // Spacing.
  static const double screenHorizontalPadding = 20;
  static const double sectionGap = 24;
  static const double featuredCardGap = 20;
  static const double gridHorizontalGap = 16;
  static const double gridVerticalGap = 20;
  static const double listGap = 16;
  static const double chipGap = 12;
  static const double chipHorizontalPadding = 20;
  static const double chipVerticalPadding = 8;

  // Search field.
  static const double searchFieldHeight = 52;
  static const double searchFieldInset = 13.5;
  static const double searchFieldIconGap = 16;

  // Icons and buttons.
  static const double iconSize = 24;
  static const double smallIconSize = 20;
  static const double languageIconSize = 28;
  static const double iconButtonSize = 44;
  static const double buttonHeight = 54;

  // Bottom navigation.
  static const double navBarHeight = 86;
  static const double navBarSidePadding = 30;
  static const double navBarIconTop = 20;
  static const double navBarIconLabelGap = 6;

  // Splash (Figma `1:4552`).
  static const double splashLogoWidth = 133.885;
  static const double splashLogoHeight = 112.445;
  static const double splashLogoTextGap = 12;
  static const double splashTitleTaglineGap = 10;

  // Auth (Figma `1:4499`).

  /// Collage top below the status bar (Figma: 83 from the frame top − 44).
  static const double authCollageTop = 39;

  /// Collage `1:4521` as exported, including its 16 px side insets.
  static const double authCollageWidth = 399;
  static const double authCollageHeight = 552;

  /// Fade above the text panel: from where the collage fade turns solid
  /// (y 568) to the first text line (y 602). Keeps text readable when a short
  /// screen moves the panel up over the photos.
  static const double authPanelFadeHeight = 34;

  static const double authTextGap = 12;
  static const double authTextButtonGap = 20;
  static const double authButtonVerticalPadding = 18;
  static const double authButtonIconSize = 22;
  static const double authButtonIconGap = 10;

  /// Not in Figma: accessibility minimum for tap targets, kept unscaled so
  /// small screens don't shrink it.
  static const double minTapTarget = 44;

  // Home (Figma `1:4426`).

  /// Header top below the status bar (Figma: 60 from the frame top − 44).
  static const double homeHeaderTop = 16;
  static const double homeAvatarSize = 44;
  static const double homeAvatarTextGap = 10;
  static const double homeSectionTitleContentGap = 20;

  /// Gap from the Featured cards to the "Our Recommendation" title.
  static const double homeFeaturedRecommendationGap = 32;

  /// Figma grid card width (2 columns of 187 in a 390 row). Wider screens fit
  /// more columns of at least this many logical pixels.
  static const double gridCardMinWidth = 187;
  static const int gridMinColumns = 2;
  static const int gridMaxColumns = 4;

  // Featured card.
  static const double featuredCardWidth = 250;
  static const double featuredCardHeight = 340;

  /// Heart in the featured price row (`I1:4470;85001:13415`).
  static const double featuredHeartSize = 22;

  /// Share of the card height covered by the bottom gradient.
  static const double featuredGradientFraction = 0.465;

  /// [S] Content inset from the start, end and bottom card edges.
  static const double featuredContentHorizontalPadding = 16;
  static const double featuredContentBottomPadding = 20;

  /// [S] Gaps title → location → price.
  static const double featuredTitleLocationGap = 8;
  static const double featuredLocationPriceGap = 10;

  // Grid card.
  static const double gridImageWidth = 159;
  static const double gridImageHeight = 154;
  static const double gridCardPaddingTop = 16;
  static const double gridCardPaddingSide = 14;
  static const double gridCardPaddingBottom = 20;
  static const double gridImageContentGap = 12;
  static const double gridContentPriceGap = 10;

  /// Heart in the grid price row (`I1:4473;85001:13433`).
  static const double gridHeartSize = 20;

  /// [S] Gap title → location in grid cards.
  static const double gridTitleLocationGap = 8;

  // List card.
  static const double listImageSize = 100;
  static const double listCardHeight = 128;
  static const double listCardPaddingStart = 14;
  static const double listCardPaddingEnd = 18;
  static const double listCardPaddingVertical = 14;
  static const double listImageContentGap = 14;

  /// [S] Gap title → location row in list cards.
  static const double listTitleLocationGap = 10;

  /// Not in Figma: minimum gap between two texts sharing a row, e.g. a long
  /// location next to the price.
  static const double inlineTextGap = 8;

  // Rating badge: [S] padding, icon-text gap and inset from the image corner.
  static const double badgeLargePaddingHorizontal = 10;
  static const double badgeLargeGap = 4;
  static const double badgeLargeInset = 24;
  static const double badgeMediumPaddingHorizontal = 6;
  static const double badgeMediumGap = 2;
  static const double badgeMediumInset = 12;
  static const double badgeSmallPaddingHorizontal = 5;
  static const double badgeSmallGap = 2;
  static const double badgeSmallInset = 6;
  static const double badgePaddingVertical = 4;
  static const double badgeSmallPaddingVertical = 1.5;

  // Radii.
  static const double radiusSearchField = 6;
  static const double radiusImage = 10;
  static const double radiusGridCard = 12;
  static const double radiusFeaturedCard = 20;
  static const double radiusListCard = 28;
  static const double radiusChip = 30;
  static const double radiusAuthButton = 30;
  static const double radiusPill = 100;

  // Shadows.

  /// `Card/Shadow 2`, using the blur of the generated card CSS (30).
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: ColorsApp.cardShadow,
      offset: Offset(0, 4),
      blurRadius: 30,
    ),
  ];

  static const List<BoxShadow> badgeShadow = [
    BoxShadow(
      color: ColorsApp.badgeShadow,
      offset: Offset(0, 20),
      blurRadius: 100,
    ),
  ];

  /// `Button/Shadow 1`.
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: ColorsApp.buttonShadow,
      offset: Offset(4, 8),
      blurRadius: 24,
    ),
  ];

  /// Auth Google button (`1:4547`): `drop-shadow(0 4 60 rgba(0,0,0,.2))`.
  static const List<BoxShadow> authButtonShadow = [
    BoxShadow(
      color: ColorsApp.authButtonShadow,
      offset: Offset(0, 4),
      blurRadius: 60,
    ),
  ];
}
