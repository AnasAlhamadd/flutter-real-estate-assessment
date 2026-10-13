/// Lenient readers for DummyJSON values: a wrong type or blank value becomes
/// `null` (or an empty list) instead of throwing.
///
/// Non-finite numbers (`NaN`, `Infinity`, or JSON literals like `1e400` that
/// overflow to infinity) also become `null`: they can't be shown, compared,
/// or written back with `jsonEncode`.
library;

String? readString(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

double? readDouble(Object? value) {
  final number = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value.trim()),
    _ => null,
  };
  return number != null && number.isFinite ? number : null;
}

int? readInt(Object? value) => switch (value) {
  int() => value,
  double() when value.isFinite && value == value.truncateToDouble() =>
    value.toInt(),
  String() => int.tryParse(value.trim()),
  _ => null,
};

List<String> readStringList(Object? value) => value is List
    ? value.map(readString).whereType<String>().toList(growable: false)
    : const [];

DateTime? readDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
