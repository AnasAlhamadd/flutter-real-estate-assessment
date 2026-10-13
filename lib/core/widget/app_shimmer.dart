import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';

/// Sweeps a highlight across the [SkeletonBox]es in [child], from the start
/// to the end of the reading direction. Figma has no loading design, so it
/// uses neutral tints. Static when the platform asks for reduced motion.
///
/// The animation never ends, so widget tests must `pump` instead of
/// `pumpAndSettle` while it's visible.
class AppShimmer extends StatefulWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  static const Duration period = Duration(milliseconds: 1400);

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppShimmer.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: const [
            ColorsApp.skeletonBase,
            ColorsApp.skeletonHighlight,
            ColorsApp.skeletonBase,
          ],
          stops: const [0.3, 0.5, 0.7],
          transform: _SweepTransform(_controller.value),
        ).createShader(bounds, textDirection: direction),
        child: child,
      ),
    );
  }
}

class _SweepTransform extends GradientTransform {
  const _SweepTransform(this.progress);

  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final offset = bounds.width * (progress * 2 - 1);
    final dx = textDirection == TextDirection.rtl ? -offset : offset;
    return Matrix4.translationValues(dx, 0, 0);
  }
}

/// A [SkeletonBox] as tall as one line of [style] in the current font and
/// text scale, bottom-aligned in at least [minHeight] (e.g. a price row as
/// tall as its heart).
class SkeletonTextLine extends StatelessWidget {
  const SkeletonTextLine({
    required this.style,
    required this.widthFactor,
    required this.radius,
    this.minHeight = 0,
    super.key,
  });

  final TextStyle style;
  final double widthFactor;
  final double radius;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final lineHeight = _lineHeight(context);
    return SizedBox(
      height: math.max(lineHeight, minHeight),
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: SkeletonBox(height: lineHeight, radius: radius),
        ),
      ),
    );
  }

  /// Measured like `Text` lays it out, so it matches the real text.
  double _lineHeight(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: ' ',
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

/// A placeholder shape for skeletons inside an [AppShimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({this.width, this.height, this.radius = 0, super.key});

  final double? width;
  final double? height;

  /// Logical pixels, already scaled by the caller.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ColorsApp.skeletonBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
