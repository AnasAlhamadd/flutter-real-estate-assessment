import 'package:flutter_real_estate_assessment/feature/properties/data/model/json_readers.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';

class CategoryModel {
  const CategoryModel({required this.slug, required this.name});

  /// Throws [FormatException] when [value] isn't a list. Accepts the current
  /// `{slug, name, url}` objects and plain slug strings; skips anything else.
  static List<CategoryModel> listFromJson(Object? value) {
    if (value is! List) {
      throw const FormatException('Categories response is not a list');
    }
    return value
        .map(_tryParse)
        .whereType<CategoryModel>()
        .toList(growable: false);
  }

  static CategoryModel? _tryParse(Object? item) {
    if (item is Map<String, dynamic>) {
      final slug = readString(item['slug']);
      if (slug == null) return null;
      return CategoryModel(slug: slug, name: readString(item['name']) ?? slug);
    }
    final slug = readString(item);
    return slug == null ? null : CategoryModel(slug: slug, name: slug);
  }

  final String slug;
  final String name;

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name};

  CategoryEntity toEntity() => CategoryEntity(slug: slug, name: name);
}
