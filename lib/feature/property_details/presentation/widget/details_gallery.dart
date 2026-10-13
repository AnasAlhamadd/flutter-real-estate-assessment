import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_network_image.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Gallery" (Figma `1:4366`): up to three square tiles. When there are
/// more photos, the last tile shows how many are left ("3+"). Tapping a tile
/// opens that photo in the hero.
class DetailsGallery extends StatelessWidget {
  const DetailsGallery({
    required this.imageUrls,
    required this.onImageTap,
    super.key,
  });

  final List<String> imageUrls;
  final ValueChanged<int> onImageTap;

  static const int tiles = AppSizes.detailsGalleryTiles;

  /// Photos not shown as tiles, announced on the last tile.
  int get hiddenCount =>
      imageUrls.length > tiles ? imageUrls.length - tiles : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          AppTextKeys.detailsGallery,
          style: AppTextStyles.sectionTitle,
        ),
        SizedBox(height: AppSizes.detailsGalleryTitleGap.h),
        Row(
          children: [
            for (var index = 0; index < tiles; index++) ...[
              if (index > 0) SizedBox(width: AppSizes.detailsGalleryTileGap.w),
              Expanded(
                child: index < imageUrls.length
                    ? _GalleryTile(
                        url: imageUrls[index],
                        index: index,
                        total: imageUrls.length,
                        hiddenCount: index == tiles - 1 ? hiddenCount : 0,
                        onTap: () => onImageTap(index),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.url,
    required this.index,
    required this.total,
    required this.hiddenCount,
    required this.onTap,
  });

  final String url;
  final int index;
  final int total;
  final int hiddenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusImage.r);
    return Semantics(
      button: true,
      label: context.tr(
        AppTextKeys.detailsShowImage,
        namedArgs: {'index': '${index + 1}', 'total': '$total'},
      ),
      excludeSemantics: true,
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: url),
              if (hiddenCount > 0) _HiddenCount(count: hiddenCount),
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma's "20+" sits on a dark photo. API photos are mostly on white, so
/// the overlay token keeps the white label readable.
class _HiddenCount extends StatelessWidget {
  const _HiddenCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ColorsApp.overlay,
      child: Center(
        child: CustomText.plain(
          '$count+',
          textDirection: TextDirection.ltr,
          style: AppTextStyles.detailsGalleryMore,
        ),
      ),
    );
  }
}
