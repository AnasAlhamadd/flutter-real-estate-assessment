import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Static map of Figma `1:4385` (approved 2026-10-13 instead of a real map
/// package): drawn at its 388 × 200 design size and scaled as one picture
/// to the width it gets, so the pin and street names stay on the art. A map
/// isn't mirrored in Arabic.
class DetailsMap extends StatelessWidget {
  const DetailsMap({super.key});

  /// this mock: the street names printed on the Figma map art (`1:4396`–
  /// `1:4399`); there's no real map or address lookup behind them.
  static const List<({String text, Rect box, double degrees})> streetNames = [
    (
      text: '9 Evergreen Center',
      box: Rect.fromLTWH(50.032, 151, 91.1, 33.575),
      degrees: 13.99,
    ),
    (
      text: '657 Lukken Court',
      box: Rect.fromLTWH(234.47, 18.726, 76.51, 53.327),
      degrees: -31.67,
    ),
    (
      text: '59797 Elka Trail',
      box: Rect.fromLTWH(332.863, 116, 41.75, 70.463),
      degrees: -64.95,
    ),
    (
      text: '488 Farwell Road',
      box: Rect.fromLTWH(39.821, 35, 81.32, 17.495),
      degrees: -3.93,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.detailsMapSize;
    return Semantics(
      image: true,
      label: context.tr(AppTextKeys.detailsMap),
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: size.aspectRatio,
          child: FittedBox(
            child: SizedBox.fromSize(
              size: size,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: MediaQuery.withNoTextScaling(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMap),
                    child: const _MapArt(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapArt extends StatelessWidget {
  const _MapArt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fromRect(
          rect: AppSizes.detailsMapArtOffset & AppSizes.detailsMapArtSize,
          child: SvgPicture.asset(ImagePath.detailsMap, fit: BoxFit.fill),
        ),
        for (final street in DetailsMap.streetNames)
          Positioned.fromRect(
            rect: street.box,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Transform.rotate(
                angle: street.degrees * math.pi / 180,
                child: Text(
                  street.text,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.mapLabel,
                ),
              ),
            ),
          ),
        Positioned.fromRect(
          rect: AppSizes.detailsMapPinOffset & AppSizes.detailsMapPinSize,
          child: SvgPicture.asset(ImagePath.mapPin, fit: BoxFit.fill),
        ),
        Positioned.fromRect(
          rect: AppSizes.detailsMapPhotoOffset & AppSizes.detailsMapPhotoSize,
          child: const _PinPhoto(),
        ),
      ],
    );
  }
}

/// this mock: the Figma sample photo inside the pin; the API has no photo
/// for a map pin.
class _PinPhoto extends StatelessWidget {
  const _PinPhoto();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorsApp.white,
          width: AppSizes.detailsMapPhotoBorder,
        ),
      ),
      child: ClipOval(
        child: Image.asset(ImagePath.mapPinPhoto, fit: BoxFit.cover),
      ),
    );
  }
}
