import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Text for the Figma "location" line, which the API doesn't provide (Q4):
/// `brand`, else the category display name, else the category slug.
extension PropertyLocationLabel on PropertyEntity {
  String locationLabel({String? categoryName}) {
    final brandName = brand?.trim() ?? '';
    if (brandName.isNotEmpty) return brandName;
    final name = categoryName?.trim() ?? '';
    return name.isNotEmpty ? name : category;
  }
}
