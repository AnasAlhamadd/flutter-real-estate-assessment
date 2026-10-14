import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/price_range.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/filter_properties_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const filter = FilterPropertiesUseCase();

  PropertyEntity item(int id, String category, double price) => PropertyEntity(
    id: id,
    title: 'Item $id',
    price: price,
    rating: 4,
    category: category,
  );

  final items = [
    item(1, 'smartphones', 99.99),
    item(2, 'smartphones', 1099.99),
    item(3, 'mobile-accessories', 19.99),
    item(4, 'laptops', 1499.99),
  ];

  List<int> ids(List<PropertyEntity> result) =>
      result.map((property) => property.id).toList();

  test('returns every item when no filter is set', () {
    expect(ids(filter(FilterParams(items: items))), [1, 2, 3, 4]);
  });

  test('keeps only the selected category', () {
    final result = filter(
      FilterParams(items: items, categorySlugs: const {'smartphones'}),
    );

    expect(ids(result), [1, 2]);
  });

  test('keeps items in any of several selected categories', () {
    final result = filter(
      FilterParams(
        items: items,
        categorySlugs: const {'laptops', 'smartphones'},
      ),
    );

    expect(ids(result), [1, 2, 4]);
  });

  test('price bounds are inclusive', () {
    final result = filter(
      FilterParams(
        items: items,
        priceRange: const PriceRange(min: 19.99, max: 1099.99),
      ),
    );

    expect(ids(result), [1, 2, 3]);
  });

  test('combines category and price filters', () {
    final result = filter(
      FilterParams(
        items: items,
        categorySlugs: const {'smartphones'},
        priceRange: const PriceRange(min: 0, max: 100),
      ),
    );

    expect(ids(result), [1]);
  });

  test('an unknown category or empty input yields an empty list', () {
    expect(
      filter(FilterParams(items: items, categorySlugs: const {'vehicle'})),
      isEmpty,
    );
    expect(filter(const FilterParams(items: [])), isEmpty);
  });

  test('keeps the original order', () {
    final result = filter(
      FilterParams(
        items: items.reversed.toList(),
        priceRange: const PriceRange(min: 0, max: 2000),
      ),
    );

    expect(ids(result), [4, 3, 2, 1]);
  });
}
