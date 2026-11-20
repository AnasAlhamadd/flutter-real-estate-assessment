import 'package:intl/intl.dart';

/// Number formats for prices and ratings.
///
/// Both use Western digits in every locale (Q7 proposal, confirmed in Phase 6).
abstract final class Formatters {
  static final NumberFormat _wholePrice = NumberFormat('#0', 'en_US');
  static final NumberFormat _centsPrice = NumberFormat('#0.00', 'en_US');
  static final NumberFormat _rating = NumberFormat('0.0', 'en_US');

  /// Figma shows whole prices as `$12219` (dollar prefix, no grouping).
  /// API prices with cents keep two decimals, e.g. `$9.99`.
  static String price(double value) {
    final format = value == value.truncateToDouble()
        ? _wholePrice
        : _centsPrice;
    return '\$${format.format(value)}';
  }

  static String rating(double value) => _rating.format(value);
}
