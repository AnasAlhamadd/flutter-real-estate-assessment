import 'dart:convert';

import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('PropertyModel.fromJson', () {
    test('maps every approved field of a full product', () {
      final entity = PropertyModel.fromJson(
        fixtureMap('product.json'),
      ).toEntity();

      expect(entity.id, 1);
      expect(entity.title, 'Essence Mascara Lash Princess');
      expect(entity.price, 9.99);
      expect(entity.rating, 2.56);
      expect(entity.category, 'beauty');
      expect(entity.brand, 'Essence');
      expect(entity.thumbnailUrl, endsWith('/thumbnail.webp'));
      expect(entity.description, startsWith('The Essence Mascara'));
      expect(entity.discountPercentage, 10.48);
      expect(entity.stock, 99);
      expect(entity.availabilityStatus, 'In Stock');
      expect(entity.tags, ['beauty', 'mascara']);
      expect(entity.imageUrls, hasLength(1));
      expect(entity.reviews, hasLength(3));
      expect(
        entity.reviews.first,
        ReviewEntity(
          reviewerName: 'Eleanor Collins',
          comment: 'Would not recommend!',
          rating: 3,
          date: DateTime.parse('2025-04-30T09:41:02.053Z'),
        ),
      );
    });

    test('leaves detail-only fields empty for a listing item', () {
      final products =
          fixtureMap('products_page.json')['products'] as List<dynamic>;

      final entity = PropertyModel.fromJson(
        products.first as Map<String, dynamic>,
      ).toEntity();

      expect(entity.title, 'Essence Mascara Lash Princess');
      expect(entity.description, isNull);
      expect(entity.stock, isNull);
      expect(entity.availabilityStatus, isNull);
      expect(entity.tags, isEmpty);
      expect(entity.imageUrls, isEmpty);
      expect(entity.reviews, isEmpty);
    });

    test('keeps brand null when the listing omits it', () {
      final products =
          fixtureMap('products_page.json')['products'] as List<dynamic>;
      final withoutBrand = products.cast<Map<String, dynamic>>().firstWhere(
        (product) => product['id'] == 16,
      );

      expect(PropertyModel.fromJson(withoutBrand).brand, isNull);
    });

    test('falls back to safe defaults when fields are missing', () {
      final entity = PropertyModel.fromJson(
        fixtureMap('product_missing_fields.json'),
      ).toEntity();

      expect(entity.id, 42);
      expect(entity.title, 'Bare Product');
      expect(entity.price, 0);
      expect(entity.rating, 0);
      expect(entity.category, isEmpty);
      expect(entity.brand, isNull);
      expect(entity.thumbnailUrl, isNull);
      expect(entity.imageUrls, isEmpty);
      expect(entity.reviews, isEmpty);
    });

    test('tolerates wrong types without throwing', () {
      final entity = PropertyModel.fromJson(
        fixtureMap('product_wrong_types.json'),
      ).toEntity();

      expect(entity.price, 9.99, reason: 'numeric strings are parsed');
      expect(entity.discountPercentage, 10);
      expect(entity.rating, 0);
      expect(entity.stock, 3, reason: 'whole doubles become ints');
      expect(entity.description, isNull);
      expect(entity.category, isEmpty);
      expect(entity.brand, isNull, reason: 'blank strings become null');
      expect(entity.availabilityStatus, isNull);
      expect(entity.tags, isEmpty);
      expect(entity.thumbnailUrl, isNull);
      expect(entity.imageUrls, ['https://cdn.dummyjson.com/a.webp']);
      expect(entity.reviews, const [
        ReviewEntity(reviewerName: 'Ann', comment: 'Fine', rating: 4),
      ]);
    });

    group('non-finite numbers fall back like missing values', () {
      for (final value in <Object>[
        'NaN',
        'Infinity',
        '-Infinity',
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        test('$value (${value.runtimeType})', () {
          final model = PropertyModel.fromJson({
            'id': 1,
            'price': value,
            'rating': value,
            'discountPercentage': value,
            'stock': value,
          });

          expect(model.price, 0);
          expect(model.rating, 0);
          expect(model.discountPercentage, isNull);
          expect(model.stock, isNull);
          expect(() => jsonEncode(model.toJson()), returnsNormally);
        });
      }

      test('a JSON literal that overflows to infinity', () {
        final json =
            jsonDecode('{"id": 1, "price": 1e400, "stock": -1e400}')
                as Map<String, dynamic>;

        final model = PropertyModel.fromJson(json);

        expect(model.price, 0);
        expect(model.stock, isNull);
      });
    });

    test('throws FormatException when the id is missing or invalid', () {
      expect(
        () => PropertyModel.fromJson(const {'title': 'No id'}),
        throwsFormatException,
      );
      expect(
        () => PropertyModel.fromJson(const {'id': 'abc'}),
        throwsFormatException,
      );
    });
  });

  test('toJson output is read back to an equal entity', () {
    final original = PropertyModel.fromJson(fixtureMap('product.json'));

    final restored = PropertyModel.fromJson(original.toJson());

    expect(restored.toEntity(), original.toEntity());
  });
}
