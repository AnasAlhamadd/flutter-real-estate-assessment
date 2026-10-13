import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/constant/image_path.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_svg_icon.dart';
import 'package:flutter_real_estate_assessment/core/widget/circle_icon_button.dart';

/// Appears once [controller] is scrolled more than one screen down, and
/// scrolls back to the top when tapped. Not in Figma: built from the primary
/// color, the button shadow and the Figma chevron turned upwards.
class ScrollToTopButton extends StatefulWidget {
  const ScrollToTopButton({required this.controller, super.key});

  final ScrollController controller;

  static const Duration fadeDuration = Duration(milliseconds: 200);
  static const Duration scrollDuration = Duration(milliseconds: 500);

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void didUpdateWidget(ScrollToTopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_update);
    widget.controller.addListener(_update);
    _update();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final controller = widget.controller;
    final visible =
        controller.hasClients &&
        controller.position.pixels > controller.position.viewportDimension;
    if (visible != _visible) setState(() => _visible = visible);
  }

  void _scrollToTop() {
    final controller = widget.controller;
    if (!controller.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpTo(0);
      return;
    }
    controller.animateTo(
      0,
      duration: ScrollToTopButton.scrollDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_visible,
      child: ExcludeSemantics(
        excluding: !_visible,
        child: AnimatedScale(
          scale: _visible ? 1 : 0,
          duration: ScrollToTopButton.fadeDuration,
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppSizes.buttonShadow,
            ),
            child: CircleIconButton(
              backgroundColor: ColorsApp.primary,
              semanticLabel: context.tr(AppTextKeys.commonBackToTop),
              onPressed: _scrollToTop,
              icon: const RotatedBox(
                quarterTurns: 3,
                child: AppSvgIcon(
                  ImagePath.arrowRight,
                  size: AppSizes.iconSize,
                  color: ColorsApp.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
