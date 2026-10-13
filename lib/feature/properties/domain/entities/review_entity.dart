import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.reviewerName,
    required this.comment,
    required this.rating,
    this.date,
  });

  final String reviewerName;
  final String comment;
  final int rating;
  final DateTime? date;

  @override
  List<Object?> get props => [reviewerName, comment, rating, date];
}
