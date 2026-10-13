import 'dart:convert';

import 'package:flutter_real_estate_assessment/feature/properties/data/model/properties_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  PropertiesResponseModel parse(String name) =>
      PropertiesResponseModel.fromJson(fixtureMap(name));

  test('parses the first page and reports more pages', () {
    final page = parse('products_page.json').toEntity();

    expect(page.items, hasLength(20));
    expect(page.total, 194);
    expect(page.hasReachedMax, isFalse);
    expect(page.isFromCache, isFalse);
  });

  test('reports the end on the last category page', () {
    final page = parse('category_last_page.json').toEntity();

    expect(page.items, hasLength(7));
    expect(page.total, 27);
    expect(page.hasReachedMax, isTrue);
  });

  test('a full set (limit=0) is complete in one response', () {
    final page = parse('search_results.json').toEntity();

    expect(page.items, hasLength(23));
    expect(page.hasReachedMax, isTrue);
  });

  for (final name in ['category_unknown.json', 'search_empty.json']) {
    test('$name is an empty, complete result', () {
      final page = parse(name).toEntity();

      expect(page.items, isEmpty);
      expect(page.total, 0);
      expect(page.hasReachedMax, isTrue);
    });
  }

  test('throws FormatException when products is not a list', () {
    expect(() => parse('products_not_a_list.json'), throwsFormatException);
  });

  test('skips entries that are not objects or have no id', () {
    final model = PropertiesResponseModel.fromJson(const {
      'products': [
        {'id': 1, 'title': 'Kept'},
        'not an object',
        {'title': 'No id'},
      ],
      'total': 3,
      'skip': 0,
      'limit': 3,
    });

    expect(model.products.map((product) => product.id), [1]);
    expect(model.total, 3);
  });

  test('defaults total, skip and limit when they are missing', () {
    final model = PropertiesResponseModel.fromJson(const {
      'products': [
        {'id': 1},
      ],
    });

    expect(model.total, 1);
    expect(model.skip, 0);
    expect(model.limit, 1);
    expect(model.toEntity().hasReachedMax, isTrue);
  });

  test('non-finite counts fall back like missing ones', () {
    final model = PropertiesResponseModel.fromJson(
      jsonDecode('{"products": [{"id": 1}], "total": 1e400, "limit": -1e400}')
          as Map<String, dynamic>,
    );

    expect(model.total, 1);
    expect(model.limit, 1);
  });

  test('toEntity marks cached pages', () {
    final cachedAt = DateTime.utc(2026, 10, 13);

    final page = parse(
      'products_page.json',
    ).toEntity(isFromCache: true, cachedAt: cachedAt);

    expect(page.isFromCache, isTrue);
    expect(page.cachedAt, cachedAt);
  });

  test('toJson output is read back to an equal page', () {
    final original = parse('products_page.json');

    final restored = PropertiesResponseModel.fromJson(original.toJson());

    expect(restored.toEntity(), original.toEntity());
  });
}
