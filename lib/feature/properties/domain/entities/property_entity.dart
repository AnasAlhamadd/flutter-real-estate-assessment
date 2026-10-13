import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';

/// A DummyJSON product presented as a property.
///
/// Listing requests only provide [id], [title], [price], [rating],
/// [category], [brand] and [thumbnailUrl]. The remaining fields are filled by
/// the details request and stay `null` or empty for listing items.
/// [stock] and [availabilityStatus] are product data and must never be shown
/// as bedrooms, bathrooms, or area.
class PropertyEntity extends Equatable {
  const PropertyEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.category,
    this.brand,
    this.thumbnailUrl,
    this.description,
    this.discountPercentage,
    this.stock,
    this.availabilityStatus,
    this.tags = const [],
    this.imageUrls = const [],
    this.reviews = const [],
  });

  final int id;
  final String title;
  final double price;
  final double rating;

  /// Category slug, e.g. `home-decoration`.
  final String category;
  final String? brand;
  final String? thumbnailUrl;
  final String? description;
  final double? discountPercentage;
  final int? stock;
  final String? availabilityStatus;
  final List<String> tags;
  final List<String> imageUrls;
  final List<ReviewEntity> reviews;

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    rating,
    category,
    brand,
    thumbnailUrl,
    description,
    discountPercentage,
    stock,
    availabilityStatus,
    tags,
    imageUrls,
    reviews,
  ];
}
