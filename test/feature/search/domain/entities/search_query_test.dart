import 'package:flutter_real_estate_assessment/feature/search/domain/entities/search_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalize', () {
    test('trims the ends', () {
      expect(SearchQuery.normalize('  phone \n'), 'phone');
    });

    test('collapses inner whitespace to one space', () {
      expect(SearchQuery.normalize('red \t  lipstick'), 'red lipstick');
    });

    test('lower-cases, so different cases share one query', () {
      expect(SearchQuery.normalize('iPhone'), SearchQuery.normalize('IPHONE'));
    });

    test('leaves Arabic text intact apart from spacing', () {
      expect(SearchQuery.normalize('  شقة   فاخرة '), 'شقة فاخرة');
    });

    test('turns whitespace-only text into an empty query', () {
      expect(SearchQuery.normalize('   '), isEmpty);
    });
  });

  group('isSearchable', () {
    test('rejects queries shorter than the minimum', () {
      expect(SearchQuery.isSearchable(''), isFalse);
      expect(SearchQuery.isSearchable('a'), isFalse);
    });

    test('accepts queries at the minimum length', () {
      expect(SearchQuery.isSearchable('ab'), isTrue);
    });

    test('counts characters, not UTF-16 units', () {
      expect(SearchQuery.isSearchable('😀'), isFalse);
      expect(SearchQuery.isSearchable('شق'), isTrue);
    });
  });
}
