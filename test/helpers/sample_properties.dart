import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// Sample listing items. No thumbnails, so widget tests never download.
const List<PropertyEntity> sampleProperties = [
  PropertyEntity(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    price: 9.99,
    rating: 4.94,
    category: 'beauty',
    brand: 'Essence',
  ),
  PropertyEntity(
    id: 2,
    title: 'Eyeshadow Palette with Mirror',
    price: 19.99,
    rating: 3.28,
    category: 'beauty',
  ),
  PropertyEntity(
    id: 3,
    title: 'Annibale Colombo Bed',
    price: 1899.99,
    rating: 4.14,
    category: 'furniture',
    brand: 'Annibale Colombo',
  ),
  PropertyEntity(
    id: 4,
    title: 'Wooden Bathroom Sink With Mirror',
    price: 799.99,
    rating: 3.59,
    category: 'furniture',
  ),
  PropertyEntity(
    id: 5,
    title: 'Calvin Klein CK One',
    price: 49.99,
    rating: 4.85,
    category: 'fragrances',
    brand: 'Calvin Klein',
  ),
];

const List<CategoryEntity> sampleCategories = [
  CategoryEntity(slug: 'beauty', name: 'Beauty'),
  CategoryEntity(slug: 'fragrances', name: 'Fragrances'),
  CategoryEntity(slug: 'furniture', name: 'Furniture'),
];

PropertiesPageEntity pageOf(
  List<PropertyEntity> items, {
  bool isFromCache = false,
  bool hasReachedMax = true,
}) => PropertiesPageEntity(
  items: items,
  total: items.length,
  hasReachedMax: hasReachedMax,
  isFromCache: isFromCache,
);
