import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';

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

/// Full details of `sampleProperties.first`. Empty image URLs show the
/// placeholder, so widget tests never download.
final PropertyEntity sampleDetailedProperty = PropertyEntity(
  id: 1,
  title: 'Essence Mascara Lash Princess',
  price: 9.99,
  rating: 4.94,
  category: 'beauty',
  brand: 'Essence',
  description:
      'The Essence Mascara Lash Princess is a popular mascara known for its '
      'volumizing and lengthening effects.',
  imageUrls: const ['', '', '', '', ''],
  reviews: [
    ReviewEntity(
      reviewerName: 'Eleanor Collins',
      comment: 'Would not recommend!',
      rating: 3,
      date: DateTime.utc(2026, 10, 7, 12),
    ),
    ReviewEntity(
      reviewerName: 'Lucas Gordon',
      comment: 'Very satisfied!',
      rating: 4,
      date: DateTime.utc(2026, 10, 13, 11, 30),
    ),
    ReviewEntity(
      reviewerName: 'Eleanor Collins',
      comment: 'Highly impressed!',
      rating: 5,
      date: DateTime.utc(2025, 10, 1),
    ),
  ],
);

/// "Now" for review times: the first review is 6 days old (Figma "6 days ago").
final DateTime sampleNow = DateTime.utc(2026, 10, 13, 12);

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
