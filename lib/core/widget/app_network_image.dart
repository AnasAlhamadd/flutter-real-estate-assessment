import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';

/// Network image with the Figma placeholder (Greyscale/400) while loading,
/// on error, and for a `null` or empty [url].
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? url;
  final BorderRadius borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl.isEmpty
          ? const _ImagePlaceholder()
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              fadeInDuration: Duration.zero,
              placeholder: (_, _) => const _ImagePlaceholder(),
              errorWidget: (_, _, _) => const _ImagePlaceholder(),
            ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: ColoredBox(color: ColorsApp.greyscale400),
    );
  }
}
