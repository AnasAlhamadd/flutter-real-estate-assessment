import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/utils/formatters.dart';

/// "4.8 (3 reviews)", or just "4.8" while the reviews aren't loaded
/// ([reviewCount] `null`). The count is the number of API reviews (§4.6).
String detailsRatingText(
  BuildContext context, {
  required double rating,
  int? reviewCount,
}) {
  final formatted = Formatters.rating(rating);
  if (reviewCount == null) return formatted;
  return context.plural(
    AppTextKeys.detailsRatingReviews,
    reviewCount,
    namedArgs: {'rating': formatted},
  );
}
