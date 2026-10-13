import 'package:flutter_real_estate_assessment/feature/properties/data/model/json_readers.dart';
import 'package:flutter_real_estate_assessment/feature/properties/data/model/review_model.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

class PropertyModel {
  const PropertyModel({
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

  /// Every field except `id` is optional, because listing requests use
  /// `select` and DummyJSON omits keys a product doesn't have.
  ///
  /// Throws [FormatException] when `id` is missing or not an integer.
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final id = readInt(json['id']);
    if (id == null) throw const FormatException('Product without a valid id');
    return PropertyModel(
      id: id,
      title: readString(json['title']) ?? '',
      price: readDouble(json['price']) ?? 0,
      rating: readDouble(json['rating']) ?? 0,
      category: readString(json['category']) ?? '',
      brand: readString(json['brand']),
      thumbnailUrl: readString(json['thumbnail']),
      description: readString(json['description']),
      discountPercentage: readDouble(json['discountPercentage']),
      stock: readInt(json['stock']),
      availabilityStatus: readString(json['availabilityStatus']),
      tags: readStringList(json['tags']),
      imageUrls: readStringList(json['images']),
      reviews: ReviewModel.listFromJson(json['reviews']),
    );
  }

  /// The listing fields of [entity] only (reference §4.6), so stored
  /// snapshots stay small whether the entity came from a list or details.
  factory PropertyModel.listingFromEntity(PropertyEntity entity) =>
      PropertyModel(
        id: entity.id,
        title: entity.title,
        price: entity.price,
        rating: entity.rating,
        category: entity.category,
        brand: entity.brand,
        thumbnailUrl: entity.thumbnailUrl,
      );

  final int id;
  final String title;
  final double price;
  final double rating;
  final String category;
  final String? brand;
  final String? thumbnailUrl;
  final String? description;
  final double? discountPercentage;
  final int? stock;
  final String? availabilityStatus;
  final List<String> tags;
  final List<String> imageUrls;
  final List<ReviewModel> reviews;

  /// Uses the API key names, so the output can be read back by [fromJson].
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'rating': rating,
    'category': category,
    if (brand != null) 'brand': brand,
    if (thumbnailUrl != null) 'thumbnail': thumbnailUrl,
    if (description != null) 'description': description,
    if (discountPercentage != null) 'discountPercentage': discountPercentage,
    if (stock != null) 'stock': stock,
    if (availabilityStatus != null) 'availabilityStatus': availabilityStatus,
    if (tags.isNotEmpty) 'tags': tags,
    if (imageUrls.isNotEmpty) 'images': imageUrls,
    if (reviews.isNotEmpty)
      'reviews': reviews.map((review) => review.toJson()).toList(),
  };

  PropertyEntity toEntity() => PropertyEntity(
    id: id,
    title: title,
    price: price,
    rating: rating,
    category: category,
    brand: brand,
    thumbnailUrl: thumbnailUrl,
    description: description,
    discountPercentage: discountPercentage,
    stock: stock,
    availabilityStatus: availabilityStatus,
    tags: tags,
    imageUrls: imageUrls,
    reviews: reviews.map((review) => review.toEntity()).toList(growable: false),
  );
}
