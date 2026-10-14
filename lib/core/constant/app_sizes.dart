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

  /// Gap title → location in list cards.
  static const double listTitleLocationGap = 10;

  /// End column `1:4181`: heart on top, price at the bottom, 10 from the
  /// card padding, 54 wide in Figma and 8 after the text.
  static const double listHeartSize = 22;
  static const double listEndColumnPadding = 10;
  static const double listEndColumnMinWidth = 54;
  static const double listContentEndGap = 8;

  // Explore / Search (Figma `1:4120`).

  /// Header top below the status bar (Figma: 60 from the frame top − 44).
  static const double searchHeaderTop = 16;

  /// Gap from the search field to "Found {n}" (Figma 24 to the chips, which
  /// wait for the Filter task) and from it to the list.
  static const double searchSectionGap = 24;

  /// Skeleton cards shown while the first page loads (about one screen).
  static const int searchSkeletonCount = 4;

  /// Not in Figma: minimum gap between two texts sharing a row, e.g. a long
  /// location next to the price.
  static const double inlineTextGap = 8;

  // Filter sheet (Figma `1:3867`).

  /// Sheet `1:3970`: 758 of the 932 design height, top corners 24. The sheet
  /// is as tall as its content, up to this share of the screen.
  static const double filterSheetMaxHeightFactor = 758 / 932;
  static const double radiusFilterSheet = 24;

  /// Content `1:3971` starts 24 below the sheet top.
  static const double filterSheetTop = 24;

  /// Back button `1:3973`: 32 circle with a 20 px arrow, kept in a
  /// [minTapTarget] square centered on it.
  static const double filterBackButtonSize = 32;

  /// Popup title → sections 32, sections 30 apart, title → content 16.
  static const double filterTitleSectionsGap = 32;
  static const double filterSectionGap = 30;
  static const double filterSectionTitleGap = 16;

  /// Property Type chips `1:4014`: wrap with 10 px gaps, 4 px vertical
  /// padding.
  static const double filterChipGap = 10;
  static const double filterChipVerticalPadding = 4;

  /// Price range `1:3981`: bars 58 high, 15.47 wide at a 19.47 pitch; the
  /// shortest bar is 3. Slider `1:4004` centered on the bars' bottom edge:
  /// track 4, thumbs 24 with a 3 px border; labels 8 below the thumbs.
  static const double filterHistogramHeight = 58;
  static const double filterHistogramBarGap = 4;
  static const double filterHistogramMinBarHeight = 3;
  static const double filterSliderTrackHeight = 4;
  static const double filterSliderThumbSize = 24;
  static const double filterSliderThumbBorder = 3;
  static const double filterPriceLabelGap = 8;

  /// Not in Figma: below this distance (share of the track) the two price
  /// labels would overlap, so one "min – max" label is shown instead.
  static const double filterPriceLabelsMergeDistance = 0.25;

  /// "Set Filter" `1:4053`: 14 above the 34 px home indicator.
  static const double filterButtonBottom = 14;

  // Property Details (Figma `1:4236`).

  /// Hero `1:4239`. Figma draws the hero and body 428 wide in a 430 frame;
  /// the app uses the full width.
  static const double detailsHeroHeight = 460;

  /// Hero scroll effects (not in Figma; your request 2026-10-13): blur once
  /// the hero has scrolled fully away, and the bottom gradient's height.
  static const double detailsHeroMaxBlur = 10;
  static const double detailsHeroGradientHeight = 120;

  /// Top bar `1:4266`: 16 below the status bar, 48 high, 24 side padding.
  static const double detailsTopBarTop = 16;
  static const double detailsTopBarHeight = 48;
  static const double detailsTopBarPadding = 24;
  static const double detailsTopBarIconSize = 28;

  /// Hero page dots `1:4240`: 16 above the hero bottom.
  static const double detailsDotsBottom = 16;
  static const double detailsDotActiveWidth = 32;
  static const double detailsDotSize = 8;
  static const double detailsDotGap = 6;

  /// Body `1:4273`: 20 × 24 padding, 30 between sections.
  static const double detailsBodyVerticalPadding = 24;
  static const double detailsSectionGap = 30;
  static const double detailsTitleRowGap = 16;
  static const double detailsTagRatingGap = 10;

  /// Tag `1:4277`.
  static const double detailsTagPaddingHorizontal = 10;
  static const double detailsTagPaddingVertical = 6;
  static const double radiusTag = 20;

  /// Rating `1:4278`: star 20, gap 6.
  static const double detailsRatingIconSize = 20;
  static const double detailsRatingIconGap = 6;

  /// Overview `1:4311`: title → text.
  static const double detailsOverviewGap = 12;

  /// Gallery `1:4366`: title → tiles, three 118 tiles spread over 388.
  static const double detailsGalleryTitleGap = 20;
  static const double detailsGalleryTileGap = 17;
  static const int detailsGalleryTiles = 3;

  /// Reviews `1:4400`: summary row → review, star 24, star → text 12.
  static const double detailsReviewsGap = 24;
  static const double detailsReviewsStarSize = 24;
  static const double detailsReviewsStarGap = 12;

  /// Review `1:4406`: avatar 40, avatar → name 10, rows 12 apart.
  static const double detailsReviewAvatarSize = 40;
  static const double detailsReviewAvatarGap = 10;
  static const double detailsReviewContentGap = 12;

  /// Stats row `1:4281`: icon 16 in a circle with 12 padding, icon → label 8,
  /// 24 between stats.
  static const double detailsStatsGap = 24;
  static const double detailsStatIconSize = 16;
  static const double detailsStatIconPadding = 12;
  static const double detailsStatLabelGap = 8;

  /// Agent `1:4308`: title → row 16, photo 60, photo → name 20, name → role
  /// 4, info → actions 12, chat → call 20, action icons 28.
  static const double detailsAgentTitleGap = 16;
  static const double detailsAgentAvatarSize = 60;
  static const double detailsAgentAvatarGap = 20;
  static const double detailsAgentNameGap = 4;
  static const double detailsAgentActionsGap = 12;
  static const double detailsAgentActionGap = 20;
  static const double detailsAgentActionIconSize = 28;

  /// Facilities `1:4314`: title → grid 20, rows 20 apart, 4 per row 8 apart,
  /// icon 28 in a circle with 16 padding, circle → label 8.
  static const double detailsFacilitiesTitleGap = 20;
  static const double detailsFacilitiesRowGap = 20;
  static const int detailsFacilitiesPerRow = 4;
  static const double detailsFacilityGap = 8;
  static const double detailsFacilityIconSize = 28;
  static const double detailsFacilityIconPadding = 16;

  /// Location `1:4380`: title → address → map 20 apart, pin icon 20 + gap 8.
  static const double detailsLocationGap = 20;
  static const double detailsLocationIconSize = 20;
  static const double detailsLocationIconGap = 8;

  /// Map `1:4385`, drawn at 388 × 200 and scaled as one picture: corners 24,
  /// map art `1:4387` (437.011 × 926) offset by (-24.505, -363), pin `1:4391`
  /// (53.1365 × 61.4796) at (167.453, 69) with a 32.674 × 32 photo at
  /// (177.663, 79) and a 3 px white border.
  static const Size detailsMapSize = Size(388, 200);
  static const double radiusMap = 24;
  static const Size detailsMapArtSize = Size(437.011, 926);
  static const Offset detailsMapArtOffset = Offset(-24.505, -363);
  static const Size detailsMapPinSize = Size(53.1365, 61.4796);
  static const Offset detailsMapPinOffset = Offset(167.453, 69);
  static const Size detailsMapPhotoSize = Size(32.674, 32);
  static const Offset detailsMapPhotoOffset = Offset(177.663, 79);
  static const double detailsMapPhotoBorder = 3;

  /// Review likes `1:4415`: heart 20, heart → count 6.
  static const double detailsReviewLikeIconSize = 20;
  static const double detailsReviewLikeGap = 6;

  /// Price bar `1:4420`: padding 24 / 24 / 36, top corners 36,
  /// "PRICE" → price 6, price → "Booking Now" 60.
  static const double detailsPriceBarTop = 24;
  static const double detailsPriceBarSide = 24;
  static const double detailsPriceBarBottom = 36;
  static const double detailsPriceLabelGap = 6;
  static const double detailsPriceButtonGap = 60;
  static const double radiusPriceBar = 36;

  // Profile (Figma `1:3786`).

  /// Header `1:3808`: 16 below the status bar (60 − 44), 44 high, content
  /// 16 below it.
  static const double profileHeaderTop = 16;
  static const double profileHeaderHeight = 44;
  static const double profileHeaderContentGap = 16;

  /// Avatar `1:3817` 140, avatar → name 14, name → divider → rows 24.
  static const double profileAvatarSize = 140;
  static const double profileAvatarNameGap = 14;
  static const double profileDividerGap = 24;

  /// Menu rows `1:3821`…`1:3854`: 28 high and 24 apart, icon 28
  /// ([languageIconSize]), icon → label 12, chevron 20 ([smallIconSize]).
  static const double profileMenuRowHeight = 28;
  static const double profileMenuRowGap = 24;
  static const double profileMenuIconGap = 12;

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
