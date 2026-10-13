import 'package:flutter_real_estate_assessment/feature/properties/data/model/category_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  test('parses the 24 API categories', () {
    final categories = CategoryModel.listFromJson(
      fixtureList('categories.json'),
    ).map((model) => model.toEntity()).toList();

    expect(categories, hasLength(24));
    expect(
      categories.first,
      const CategoryEntity(slug: 'beauty', name: 'Beauty'),
    );
    expect(
      categories.last,
      const CategoryEntity(slug: 'womens-watches', name: 'Womens Watches'),
    );
  });

  test('accepts plain slug strings and skips invalid entries', () {
    final categories = CategoryModel.listFromJson(const [
      'laptops',
      {'slug': 'vehicle'},
      {'name': 'No slug'},
      42,
      '',
    ]);

    expect(categories.map((category) => category.toJson()), [
      {'slug': 'laptops', 'name': 'laptops'},
      {'slug': 'vehicle', 'name': 'vehicle'},
    ]);
  });

  test('throws FormatException when the response is not a list', () {
    expect(
      () => CategoryModel.listFromJson(const {'slug': 'beauty'}),
      throwsFormatException,
    );
  });
}
