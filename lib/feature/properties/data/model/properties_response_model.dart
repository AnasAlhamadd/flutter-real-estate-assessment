import 'package:flutter_real_estate_assessment/feature/properties/data/model/json_readers.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/property_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';

/// A DummyJSON list response: `{products, total, skip, limit}`.
class PropertiesResponseModel {
  const PropertiesResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  /// Throws [FormatException] when `products` isn't a list. Individual
  /// entries that aren't objects or lack an id are skipped.
  factory PropertiesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    if (rawProducts is! List) {
      throw const FormatException('`products` is not a list');
    }
    final products = <PropertyModel>[];
    for (final item in rawProducts.whereType<Map<String, dynamic>>()) {
      try {
        products.add(PropertyModel.fromJson(item));
      } on FormatException {
        continue;
      }
    }
    return PropertiesResponseModel(
      products: products,
      total: readInt(json['total']) ?? products.length,
      skip: readInt(json['skip']) ?? 0,
      // DummyJSON echoes the number of returned items in `limit`.
      limit: readInt(json['limit']) ?? rawProducts.length,
    );
  }

  final List<PropertyModel> products;
  final int total;
  final int skip;
  final int limit;

  Map<String, dynamic> toJson() => {
    'products': products.map((product) => product.toJson()).toList(),
    'total': total,
    'skip': skip,
    'limit': limit,
  };

  PropertiesPageEntity toEntity({
    bool isFromCache = false,
    DateTime? cachedAt,
  }) => PropertiesPageEntity(
    items: products
        .map((product) => product.toEntity())
        .toList(growable: false),
    total: total,
    hasReachedMax: skip + limit >= total,
    isFromCache: isFromCache,
    cachedAt: cachedAt,
  );
}
