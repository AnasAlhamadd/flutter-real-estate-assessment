import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';

/// Price distribution of a full matching set, for the Filter sheet's bars
/// and range slider.
///
/// Positions (0 to 1) follow a logarithmic scale over whole-dollar bounds:
/// DummyJSON prices run from $0.79 to $36,999.99 with most under $100, so a
/// linear scale would put nearly every product in the first bar.
class PriceHistogram extends Equatable {
  const PriceHistogram._({
    required this.min,
    required this.max,
    required this.counts,
    required this.canSelectRange,
  });

  factory PriceHistogram.of(
    Iterable<double> prices, {
    int bucketCount = defaultBucketCount,
  }) {
    assert(bucketCount > 0, 'bucketCount must be positive');
    final valid = prices.where((price) => price.isFinite && price >= 0);
    if (valid.isEmpty) {
      return PriceHistogram._(
        min: 0,
        max: 0,
        counts: List.unmodifiable(List.filled(bucketCount, 0)),
        canSelectRange: false,
      );
    }
    final lowest = valid.reduce(math.min);
    final highest = valid.reduce(math.max);
    final counts = List.filled(bucketCount, 0);
    final histogram = PriceHistogram._(
      min: lowest.floorToDouble(),
      max: highest.ceilToDouble(),
      counts: counts,
      canSelectRange: highest > lowest,
    );
    for (final price in valid) {
      final index = (histogram.positionOf(price) * bucketCount).floor();
      counts[index.clamp(0, bucketCount - 1)]++;
    }
    return PriceHistogram._(
      min: histogram.min,
      max: histogram.max,
      counts: List.unmodifiable(counts),
      canSelectRange: histogram.canSelectRange,
    );
  }

  /// About one bar per 19.5 px of the 390 px Figma chart (`1:3982`).
  static const int defaultBucketCount = 20;

  /// Lowest price rounded down to whole dollars.
  final double min;

  /// Highest price rounded up to whole dollars.
  final double max;

  /// Products per bucket, low to high prices.
  final List<int> counts;

  /// Whether there are two different prices to choose between. A single
  /// $9.99 price still gets the $9–$10 scale, but nothing to select.
  final bool canSelectRange;

  int get largestCount => counts.fold(0, math.max);

  /// Where [price] sits on the scale, clamped to 0–1.
  double positionOf(double price) {
    if (max <= min) return 0;
    final start = _scale(min);
    final position = (_scale(price) - start) / (_scale(max) - start);
    return position.clamp(0, 1).toDouble();
  }

  /// Whole-dollar price at [position] (0–1).
  double priceAt(double position) {
    if (max <= min) return min;
    final start = _scale(min);
    final scaled = start + position.clamp(0, 1) * (_scale(max) - start);
    return (math.exp(scaled) - 1).roundToDouble().clamp(min, max).toDouble();
  }

  /// The filter for slider positions. A thumb at its end of the track leaves
  /// that side open, so a later search with wider prices isn't cut off;
  /// `null` when both sides are open.
  PriceRange? rangeFor(double start, double end) {
    if (!canSelectRange) return null;
    final openStart = start <= 0;
    final openEnd = end >= 1;
    if (openStart && openEnd) return null;
    return PriceRange(
      min: openStart ? 0 : priceAt(start),
      max: openEnd ? double.infinity : priceAt(end),
    );
  }

  /// Slider positions for [range]; open or out-of-scale sides sit at the
  /// ends of the track.
  ({double start, double end}) positionsOf(PriceRange? range) {
    if (range == null || !canSelectRange) return (start: 0, end: 1);
    return (
      start: range.min <= min ? 0 : positionOf(range.min),
      end: range.max >= max ? 1 : positionOf(range.max),
    );
  }

  static double _scale(double price) => math.log(price + 1);

  @override
  List<Object?> get props => [min, max, counts, canSelectRange];
}
