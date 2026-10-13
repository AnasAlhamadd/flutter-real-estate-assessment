import 'package:equatable/equatable.dart';

/// Inclusive price bounds for the local price filter.
class PriceRange extends Equatable {
  const PriceRange({required this.min, required this.max})
    : assert(min <= max, 'min must not exceed max');

  final double min;
  final double max;

  bool contains(double price) => price >= min && price <= max;

  @override
  List<Object?> get props => [min, max];
}
