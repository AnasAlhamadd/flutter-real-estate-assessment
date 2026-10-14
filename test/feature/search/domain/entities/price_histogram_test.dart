import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';
import 'package:flutter_real_estate_assessment/feature/search/domain/entities/price_histogram.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ln(0 + 1) = 0 and ln(9999 + 1) = 4·ln(10), so $99 sits at the middle.
  final histogram = PriceHistogram.of(const [0, 99, 9999]);

  test('rounds the bounds out to whole dollars', () {
    final rounded = PriceHistogram.of(const [0.79, 36999.99]);

    expect(rounded.min, 0);
    expect(rounded.max, 37000);
  });

  test('counts every price once, cheapest first, on a log scale', () {
    final counts = PriceHistogram.of(const [
      9.99,
      19.99,
      49.99,
      799.99,
      1899.99,
    ], bucketCount: 4).counts;

    expect(counts, [2, 1, 0, 2]);
    expect(histogram.counts, hasLength(PriceHistogram.defaultBucketCount));
    expect(histogram.counts.first, 1);
    expect(histogram.counts[10], 1);
    expect(histogram.counts.last, 1);
    expect(histogram.largestCount, 1);
  });

  test('maps prices to positions and back', () {
    expect(histogram.positionOf(0), 0);
    expect(histogram.positionOf(99), closeTo(0.5, 1e-9));
    expect(histogram.positionOf(9999), 1);
    expect(histogram.positionOf(20000), 1);
    expect(histogram.priceAt(0.5), 99);
    expect(histogram.priceAt(1), 9999);
  });

  test('a thumb at an end of the track leaves that side open', () {
    expect(histogram.rangeFor(0, 1), isNull);
    expect(histogram.rangeFor(0, 0.5), const PriceRange(min: 0, max: 99));
    expect(
      histogram.rangeFor(0.5, 1),
      const PriceRange(min: 99, max: double.infinity),
    );
  });

  test('positions of a range put open or wider sides at the ends', () {
    expect(histogram.positionsOf(null), (start: 0.0, end: 1.0));

    final open = histogram.positionsOf(
      const PriceRange(min: 99, max: double.infinity),
    );
    expect(open.start, closeTo(0.5, 1e-9));
    expect(open.end, 1);

    final wider = histogram.positionsOf(const PriceRange(min: 0, max: 99999));
    expect(wider, (start: 0.0, end: 1.0));
  });

  test('no prices, or a single price, cannot be ranged', () {
    final empty = PriceHistogram.of(const []);
    final single = PriceHistogram.of(const [5, 5]);
    final fractional = PriceHistogram.of(const [9.99, 9.99]);

    expect(empty.canSelectRange, isFalse);
    expect(empty.largestCount, 0);
    expect(empty.rangeFor(0.2, 0.8), isNull);
    expect(single.canSelectRange, isFalse);
    expect(single.counts.first, 2);
    expect(single.rangeFor(0.2, 0.8), isNull);
    expect((fractional.min, fractional.max), (9.0, 10.0));
    expect(fractional.canSelectRange, isFalse);
    expect(fractional.rangeFor(0.2, 0.8), isNull);
    expect(single.positionsOf(const PriceRange(min: 1, max: 2)), (
      start: 0.0,
      end: 1.0,
    ));
  });
}
