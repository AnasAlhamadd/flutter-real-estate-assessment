import 'package:flutter_real_estate_assessment/feature/properties/data/model/json_readers.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/review_entity.dart';

class ReviewModel {
  const ReviewModel({
    required this.reviewerName,
    required this.comment,
    required this.rating,
    this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    reviewerName: readString(json['reviewerName']) ?? '',
    comment: readString(json['comment']) ?? '',
    rating: readInt(json['rating']) ?? 0,
    date: readDate(json['date']),
  );

  /// Skips entries that aren't objects or have neither a name nor a comment.
  static List<ReviewModel> listFromJson(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .where(
          (review) =>
              review.reviewerName.isNotEmpty || review.comment.isNotEmpty,
        )
        .toList(growable: false);
  }

  final String reviewerName;
  final String comment;
  final int rating;
  final DateTime? date;

  Map<String, dynamic> toJson() => {
    'reviewerName': reviewerName,
    'comment': comment,
    'rating': rating,
    if (date != null) 'date': date!.toIso8601String(),
  };

  ReviewEntity toEntity() => ReviewEntity(
    reviewerName: reviewerName,
    comment: comment,
    rating: rating,
    date: date,
  );
}
