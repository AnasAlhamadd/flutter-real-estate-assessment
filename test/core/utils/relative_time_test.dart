import 'package:flutter_real_estate_assessment/core/utils/relative_time.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.utc(2026, 10, 13, 12);

RelativeTime _ago(Duration elapsed) =>
    RelativeTimes.between(_now.subtract(elapsed), _now);

void main() {
  test('less than a minute ago is "just now"', () {
    expect(_ago(const Duration(seconds: 59)).unit, RelativeTimeUnit.justNow);
  });

  test('a future moment is "just now"', () {
    expect(
      RelativeTimes.between(_now.add(const Duration(days: 2)), _now).unit,
      RelativeTimeUnit.justNow,
    );
  });

  test('uses the largest whole unit', () {
    expect(_ago(const Duration(minutes: 1)), (
      unit: RelativeTimeUnit.minutes,
      value: 1,
    ));
    expect(_ago(const Duration(minutes: 59, seconds: 59)), (
      unit: RelativeTimeUnit.minutes,
      value: 59,
    ));
    expect(_ago(const Duration(hours: 1)), (
      unit: RelativeTimeUnit.hours,
      value: 1,
    ));
    expect(_ago(const Duration(hours: 23, minutes: 59)), (
      unit: RelativeTimeUnit.hours,
      value: 23,
    ));
    expect(_ago(const Duration(days: 6)), (
      unit: RelativeTimeUnit.days,
      value: 6,
    ));
    expect(_ago(const Duration(days: 29)), (
      unit: RelativeTimeUnit.days,
      value: 29,
    ));
  });

  test('months are 30 days and years 365 days', () {
    expect(_ago(const Duration(days: 30)), (
      unit: RelativeTimeUnit.months,
      value: 1,
    ));
    expect(_ago(const Duration(days: 364)), (
      unit: RelativeTimeUnit.months,
      value: 12,
    ));
    expect(_ago(const Duration(days: 365)), (
      unit: RelativeTimeUnit.years,
      value: 1,
    ));
    expect(_ago(const Duration(days: 800)), (
      unit: RelativeTimeUnit.years,
      value: 2,
    ));
  });
}
