import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters.price', () {
    test('formats whole prices like Figma, without grouping', () {
      expect(Formatters.price(12219), r'$12219');
      expect(Formatters.price(0), r'$0');
    });

    test('keeps two decimals for prices with cents', () {
      expect(Formatters.price(9.99), r'$9.99');
      expect(Formatters.price(10.5), r'$10.50');
      expect(Formatters.price(1234567.891), r'$1234567.89');
    });
  });

  group('Formatters.rating', () {
    test('always shows one decimal', () {
      expect(Formatters.rating(4.94), '4.9');
      expect(Formatters.rating(4.96), '5.0');
      expect(Formatters.rating(5), '5.0');
    });
  });
}
