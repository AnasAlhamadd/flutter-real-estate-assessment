import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/price_histogram.dart';
import 'package:flutter_real_estate_assessment/feature/search/presentation/widget/price_histogram_bars.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma "range" `1:3981`: price bars, a range slider centered on their
/// bottom edge, and the selected prices under the thumbs.
class PriceRangeChart extends StatelessWidget {
  const PriceRangeChart({
    required this.histogram,
    required this.start,
    required this.end,
    required this.onChanged,
    super.key,
  });

  final PriceHistogram histogram;

  /// Thumb positions on [histogram]'s scale (0–1).
  final double start;
  final double end;

  /// `null` disables the slider (fewer than two different prices).
  final void Function(double start, double end)? onChanged;

  @override
  Widget build(BuildContext context) {
    final barsHeight = AppSizes.filterHistogramHeight.h;
    final thumbSize = AppSizes.filterSliderThumbSize.r;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: barsHeight + thumbSize / 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                child: Semantics(
                  label: context.tr(AppTextKeys.filterPriceChart),
                  excludeSemantics: true,
                  child: PriceHistogramBars(counts: histogram.counts),
                ),
              ),
              PositionedDirectional(
                top: barsHeight - thumbSize / 2,
                start: 0,
                end: 0,
                height: thumbSize,
                child: _PriceSlider(
                  histogram: histogram,
                  start: start,
                  end: end,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.filterPriceLabelGap.h),
        _PriceLabels(
          startPrice: histogram.priceAt(start),
          endPrice: histogram.priceAt(end),
          start: start,
          end: end,
        ),
      ],
    );
  }
}

/// Figma slider `1:4004`: Primary 10% track with round ends, Primary active
/// segment, white thumbs with a Primary border. No padding, so the thumb
/// centers stop 2 px inside the chart edges, as in Figma.
class _PriceSlider extends StatelessWidget {
  const _PriceSlider({
    required this.histogram,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  final PriceHistogram histogram;
  final double start;
  final double end;
  final void Function(double start, double end)? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        padding: EdgeInsets.zero,
        trackHeight: AppSizes.filterSliderTrackHeight.r,
        activeTrackColor: ColorsApp.primary,
        inactiveTrackColor: ColorsApp.primary10,
        disabledActiveTrackColor: ColorsApp.primary10,
        disabledInactiveTrackColor: ColorsApp.primary10,
        overlayColor: ColorsApp.primary10,
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
        rangeThumbShape: _PriceThumbShape(
          radius: AppSizes.filterSliderThumbSize.r / 2,
          borderWidth: AppSizes.filterSliderThumbBorder.r,
        ),
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: RangeSlider(
        values: RangeValues(start, end),
        onChanged: onChanged == null
            ? null
            : (values) => onChanged(values.start, values.end),
        semanticFormatterCallback: (value) =>
            Formatters.price(histogram.priceAt(value)),
      ),
    );
  }
}

class _PriceThumbShape extends RangeSliderThumbShape {
  const _PriceThumbShape({required this.radius, required this.borderWidth});

  final double radius;
  final double borderWidth;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final circleRadius = radius - borderWidth / 2;
    context.canvas
      ..drawCircle(center, circleRadius, Paint()..color = ColorsApp.white)
      ..drawCircle(
        center,
        circleRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = isEnabled ? ColorsApp.primary : ColorsApp.primary10,
      );
  }
}

/// Figma labels `1:4009`: each price under its thumb, kept inside the chart.
/// Thumbs closer than [AppSizes.filterPriceLabelsMergeDistance] share one
/// "min – max" label so the prices never overlap.
class _PriceLabels extends StatelessWidget {
  const _PriceLabels({
    required this.startPrice,
    required this.endPrice,
    required this.start,
    required this.end,
  });

  final double startPrice;
  final double endPrice;
  final double start;
  final double end;

  @override
  Widget build(BuildContext context) {
    final startLabel = Formatters.price(startPrice);
    final endLabel = Formatters.price(endPrice);
    if (end - start < AppSizes.filterPriceLabelsMergeDistance) {
      return _label(
        startPrice == endPrice ? startLabel : '$startLabel – $endLabel',
        (start + end) / 2,
      );
    }
    return Stack(children: [_label(startLabel, start), _label(endLabel, end)]);
  }

  /// `AlignmentDirectional(2t − 1)` centers the label at the thumb in the
  /// middle and pins it to the chart edge at either end.
  static Widget _label(String text, double position) => SizedBox(
    width: double.infinity,
    child: Align(
      alignment: AlignmentDirectional(position * 2 - 1, 0),
      child: ExcludeSemantics(
        child: CustomText.plain(
          text,
          style: AppTextStyles.filterPriceLabel,
          maxLines: 1,
          textDirection: TextDirection.ltr,
        ),
      ),
    ),
  );
}
