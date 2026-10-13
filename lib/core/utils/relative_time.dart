enum RelativeTimeUnit { justNow, minutes, hours, days, months, years }

/// How long ago a moment was, in the largest whole unit, e.g. "6 days ago".
/// Months count as 30 days and years as 365 days. Moments less than a minute
/// ago, or in the future, are [RelativeTimeUnit.justNow].
typedef RelativeTime = ({RelativeTimeUnit unit, int value});

abstract final class RelativeTimes {
  static RelativeTime between(DateTime moment, DateTime now) {
    final elapsed = now.difference(moment);
    final days = elapsed.inDays;
    return switch (elapsed) {
      _ when elapsed.inMinutes < 1 => (
        unit: RelativeTimeUnit.justNow,
        value: 0,
      ),
      _ when elapsed.inHours < 1 => (
        unit: RelativeTimeUnit.minutes,
        value: elapsed.inMinutes,
      ),
      _ when days < 1 => (unit: RelativeTimeUnit.hours, value: elapsed.inHours),
      _ when days < 30 => (unit: RelativeTimeUnit.days, value: days),
      _ when days < 365 => (unit: RelativeTimeUnit.months, value: days ~/ 30),
      _ => (unit: RelativeTimeUnit.years, value: days ~/ 365),
    };
  }
}
